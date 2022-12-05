#!/bin/bash


source /shared/setup_env.sh


ARCH=$(uname -m)
#Build packages
if [ $ARCH = "x86_64"]
then
    time spack install wps %intel ^intel-oneapi-mpi #This is going to install WPS and WRF
    time spack install ncview%intel
    time spack install wgrib2%intel 
    ARCH_CONFIG=spack load wgrib2%intel
elif [ $ARCH = "aarch64"]
then
    #Remove mirrors.yaml because of errors during build
    mv ${shared_folder}/spack/etc/spack/mirrprs.yaml ${shared_folder}/spack/etc/spack/mirrprs.yaml.old
    touch ${shared_folder}/spack/etc/spack/mirrprs.yaml

    #Update packages.yaml to avoid rebuildling already installed componentis
    mv ${shared_folder}/spack/etc/spack/packages.yaml ${shared_folder}/spack/etc/spack/packages.yaml.old
    cat <<@EOF > ${shared_folder}/spack/etc/spack/packages.yaml
packages:
  zlib:
    externals:
      - spec: zlib@1.2.7
        prefix: /usr
  openmpi:
    externals:
    - spec: openmpi@4.1.1-2
      prefix: /opt/amazon/openmpi
      buildable: false
@EOF    
    cat ${shared_folder}/spack/etc/spack/packages.yaml.old| grep -v '^packages:' >> ${shared_folder}/spack/etc/spack/packages.yaml
    
    time spack install wps   #This is going to install WPS and WRF
    spack install ncview
    
    #spack install    wgrib2
    #Manual install wgrib2 because of spack open issue on Graviton2
    mkdir -p ${BUILDDIR}
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
    ARCH_CONFIG=""
@EOF
else
    echo "Unsupported Architecture $ARCH"
    exit 1
fi


cat <<@EOF >> /shared/setup_env.sh
spack load wrf
spack load wps
spack load ncview

$ARCH_CONFIG

export WRF_DIR=\$(spack location -i wrf)
export WPS_DIR=\$(spack location -i wps)
export NETCDF=\$(spack location -i netcdf-fortran)
export JASPER=\$(spack location -i jasper)

export NETCDFRLIB=\$NETCDF/lib
export NETCDFINC=\$NETCDF/include
export JASPERLIB=\$JASPER/lib
export JASPERINC=\$JASPER/include
export LD_LIBRARY_PATH=\${NETCDFRLIB}:\${JASPERLIB}:\$LD_LIBRARY_PATH

@EOF
