#!/bin/bash


source /shared/setup_env.sh

ARCH=$(uname -m)
#Build packages
if [ $ARCH = "x86_64"]
then
    time spack install wps %intel ^intel-oneapi-mpi #This is going to install WPS and WRF
    time spack install ncview
    time spack install wgrib2%intel 
    
elif [ $ARCH = "aarch64"]
then
    time spack install wps   #This is going to install WPS and WRF
    
    spack install ncview
    
    #spack install    wgrib2
    #Manual install wgrib2 because of spack open issue on Graviton2
    cd ${shared_folder}/download
    wget ftp://ftp.cpc.ncep.noaa.gov/wd51we/wgrib2/wgrib2.tgz
    ################## COMPILE wgrib2  ################################################
    cd $BUILDDIR
    tar -zxvf /shared/download/wgrib2.tgz
    cd grib2
    bash <<@EOF
    export FC=gfortran
    export COMP_SYS=gnu_linux
    export NETCDF=$(spack location -i netcdf-fortran)
    export JASPERDIR=\$(spack location -i jasper)    
    export CPPFLAGS="-I\$NETCFD/include/ -I\$JASPERDIR/include  -L\$NETCFD/lib/ -L\$JASPERDIR/lib/"
    echo "makefile < ${SETUP_DIR}/wgrib_makefile.patch"
    patch --fuzz 3 makefile < ${SETUP_DIR}/wrf_setup_scripts/wgrib_makefile.patch
    make
    cp wgrib2/wgrib2  $DIR/bin
    @EOF
else
    echo "Unsupported Architecture $ARCH"
    exit 1
fi


cat <<@EOF >> /shared/setup_env.sh
spack load wrf
spack load wps
spack load ncview


export WRF_DIR=\$(spack location -i wrf)
export WPS_DIR=\$(spack location -i wps)
export NETCDF=\$(spack location -i netcdf-fortran)
export JASPERDIR=\$(spack location -i jasper)

export JASPERLIB=\$JASPERDIR/lib
export JASPERINC=\$JASPERDIR/include


export 
@EOF

