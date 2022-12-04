#!/bin/bash


source /shared/setup_env.sh


#Build packages
spack install wps   #This is going to install WPS and WRF

spack install ncview

#spack install    wgrib2
#Manual install wgrib2 because of spack open issue on Graviton2



cat <<@EOF >> /shared/setup_env.sh
spack load wrf
spack load wps
spack load ncview


export WRF_DIR=\$(spack location -i wrf)
export WPS_DIR=\$(spack location -i wps)
export NETCDF=\$(spack location -i netcdf-fortran)
export JASPERDIR=\$(spack location -i jasper@1.900.1)

export JASPERLIB=\$JASPERDIR/lib
export JASPERINC=\$JASPERDIR/include


export 
@EOF

