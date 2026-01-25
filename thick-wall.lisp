(in-package :cl-mpm/examples/virtual-stress/thick-cylinder)

(defun plot (sim)
  (format t "~A ~%" (local-time:now)))
(defun plot-domain ()
  (format t "~A ~%" (local-time:now)))
(let ((threads (parse-integer (if (uiop:getenv "OMP_NUM_THREADS") (uiop:getenv "OMP_NUM_THREADS") "16"))))
  (setf lparallel:*kernel* (lparallel:make-kernel threads :name "custom-kernel"))
  (format t "Thread count ~D~%" threads))

(defparameter *ref* (parse-float:parse-float (if (uiop:getenv "REFINE") (uiop:getenv "REFINE") "1")))

(defparameter *top-dir* (merge-pathnames "./vtk_data/"))

(let ((stability-dir (merge-pathnames (format nil "./data/"))))
  (ensure-directories-exist stability-dir)
  (let* ((mps 2)
         (output-dir (merge-pathnames  (format nil "./output-~f-~f/" *ref* mps) *top-dir*)))
    (format t "Outputting to ~A~%" output-dir)
    (let* ()
      (setup
       :refine *ref*
       :mps mps
       :sym t
       )
      (format t "Running sim size ~a ~a ~%" *ref* mps)
      (cl-mpm/dynamic-relaxation::run-load-control
       *sim*
       :output-dir output-dir
       :load-steps 1
       :substeps (* 20 *ref*)
       :plotter #'plot
       :damping 1d0
       :save-vtk-dr nil
       :save-vtk-loadstep t
       :dt-scale 1d0
       :criteria 1d-9
       :loading-function (lambda (f) (setf (nth 1 (cl-mpm/buoyancy::bc-pressure-pressures *bc-pressure*)) (* f -1d4))))
      (save-csv (merge-pathnames (format nil "./data/data-~A_~D.csv" *ref* mps)))
      )))
