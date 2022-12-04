#!/bin/bash 
#SBATCH --error=job.err
#SBATCH --output=job.out
#SBATCH --time=24:00:00
#SBATCH --job-name=wrf
#SBATCH --nodes=6
#SBATCH --ntasks-per-node=63
#SBATCH --cpus-per-task=1

cd /shared/FORECAST/domains/test/run
mpirun  ./wrf.exe
