(in-package :cl-mpm/examples/virtual-stress/thick-cylinder)

(defun plot (sim)
  (format t "~A ~%" (local-time:now)))
(defun plot-domain ()
  (format t "~A ~%" (local-time:now)))
(let ((threads (parse-integer (if (uiop:getenv "OMP_NUM_THREADS") (uiop:getenv "OMP_NUM_THREADS") "16"))))
  ;(setf lparallel:*kernel* (lparallel:make-kernel threads :name "custom-kernel"))
  (cl-mpm/utils:set-workers threads)
  (format t "Thread count ~D~%" threads))

(defparameter *ref* (parse-float:parse-float (if (uiop:getenv "REFINE") (uiop:getenv "REFINE") "1")))

(defparameter *top-dir* (merge-pathnames "./vtk_data/"))

(let ((stability-dir (merge-pathnames (format nil "./data/"))))
  (ensure-directories-exist stability-dir)
  (let* ((mps 4)
         (output-dir (merge-pathnames  (format nil "./output-~f-~f/" *ref* mps) *top-dir*)))
    (format t "Outputting to ~A~%" output-dir)
    (let* ()
      (setup
       :refine *ref*
       :mps mps
       :sym t)
      (setf (cl-mpm/aggregate::sim-enable-aggregate *sim*) t)
      (cl-mpm/setup::set-mass-filter *sim* 1d3 :proportion 1d-15)
      (format t "Running sim size ~a ~a ~%" *ref* mps)
      (cl-mpm/dynamic-relaxation::run-load-control
       *sim*
       :output-dir output-dir
       :load-steps 10
       :substeps (* 20 *ref*)
       :plotter #'plot
       :save-vtk-dr nil
       :save-vtk-loadstep t
       :dt-scale 0.9d0
       :criteria 1d-9
       :loading-function #'loading-function)
      (save-csv (merge-pathnames (format nil "./data/data-~A_~D.csv" *ref* mps)))
      )))
