#!/bin/bash
env > /tmp/env_before

source /shared/setup_env.sh

env > /tmp/env_after

#Create Spack environment
spack env create wrf-workshop-env
spack env activate wrf-workshop-env

#Install and configure compiler and MPI libraries
spack install intel-oneapi-compilers@2021.4.0
spack compiler add `spack location -i intel-oneapi-compilers`/compiler/latest/linux/bin/intel64
spack compiler add `spack location -i intel-oneapi-compilers`/compiler/latest/linux/bin


spack config add "packages:all:compiler:[intel, oneapi, gcc]"
spack config add "packages:all:providers:mpi:[intel-oneapi-mpi]"

spack install intel-oneapi-mpi@2021.4.0%intel

spack load intel-oneapi-mpi

#Build packages
spack install    wrf@4.2%intel

spack install    wps@4.2%intel

spack install    wgrib2%intel

spack install    ncview@4.2%intel