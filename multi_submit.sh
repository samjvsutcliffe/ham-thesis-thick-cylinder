#!/bin/bash
#export OMP_PROC_BIND=spread,close
#export BLIS_NUM_THREADS=1
read -p "Do you want to clear previous data? (y/n)" yn
case $yn in
    [yY] ) echo "Removing data";rm -r ./vkt_data/output-*; rm data/*; break;;
    [nN] ) break;;
esac
set -e
module load aocc/5.0.0
module load aocl/5.0.0
sbcl --dynamic-space-size 16000 --load "build.lisp" --quit

for r in 0 1 2 3 4
do
    export REFINE=$r
    sbatch batch_tc.sh
done

