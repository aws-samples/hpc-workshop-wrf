#!/bin/bash

source /shared/setup_env.sh
cd ${TARGET_DIR}/run
echo "#################################"
env
echo "#################################"
echo  $SLURM_JOB_NODELIST
echo "#################################"

#Each process uses 2 threads and only phisical cores
let PROCESS=SLURM_NTASKS/2
PPN=18                 #c5n.18xlarge
export OMP_NUM_THREADS=2
echo "Processes $PROCESS"
time mpiexec.hydra -bootstrap slurm -np $PROCESS -ppn 18 ./wrf.exe