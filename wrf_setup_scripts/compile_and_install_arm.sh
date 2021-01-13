#!/bin/bash
env > /tmp/env_before
source /shared/setup_env.sh

env > /tmp/env_after

#Download source packages
bash download.sh
#Run Manually because it takes too much to be included in cluster preparation
#bash download_and_install_geog_data.sh &

mkdir -p $BUILDDIR
################## COMPILE HD5  ##################################################
cd $BUILDDIR
tar -zxvf /shared/download/hdf5-1.10.5.tar.gz
cd hdf5-1.10.5
./configure CC=mpicc FC=mpif90 CXX=mpicxx --enable-parallel --enable-fortran --prefix=$DIR/netcdf --with-pic
sed -i -e 's#wl=""#wl="-Wl,"#g' libtool
sed -i -e 's#pic_flag=""#pic_flag=" -fPIC -DPIC"#g' libtool
make -j 8
make install


################## COMPILE NETCDF ################################################
cd $BUILDDIR
tar -zxvf /shared/download/netcdf-c-4.7.4.tar.gz
cd netcdf-c-4.7.4

bash <<@EOF
export CC=mpicc
export CXX=mpicxx
export F77=mpif77
export FC=mpif90
export MPICC=mpicc
export MPIFC=mpif90
export MPICXX=mpicxx

./configure --prefix=$DIR/netcdf CPPFLAGS="-I$DIR/netcdf/include" CFLAGS="-DHAVE_STRDUP -O3 -mcpu=native" LDFLAGS="-L$DIR/netcdf/lib" --enable-shared --enable-netcdf-4  --with-pic --disable-doxygen --disable-dap
make -j 8
make install
@EOF

#
cd $BUILDDIR
yum -y install libcurl-devel
tar -zxvf /shared/download/netcdf-fortran-4.5.3.tar.gz
bash <<@EOF
cd netcdf-fortran-4.5.3
export CC=gcc
export CXX=g++
export F77=gfortran
export FC=gfortran
export MPICC=mpicc
export MPIFC=mpif90
export MPICXX=mpicxx

export NFDIR=$DIR/netcdf
export CFLAGS="-L$DIR/netcdf/lib -I$DIR/netcdf/include" 
export CXXFLAGS="-L$DIR/netcdf/lib -I$DIR/netcdf/include"
export FCFLAGS="-L$DIR/netcdf/lib -I$DIR/netcdf/include"
export FFLAGS="-L$DIR/netcdf/lib -I$DIR/netcdf/include"
export LDFLAGS="-L$DIR/netcdf/lib"
export LIBS=" -lnetcdf -lhdf5_hl -lhdf5 -lz -lcurl"
# Need netcdf, hdf5 and libcurl libs in library path to allow configure tests to succeed
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DIR/netcdf/lib
./configure  --prefix=$DIR/netcdf --enable-shared --with-pic --disable-doxygen
make -j 8
make check
make install
@EOF

################## COMPILE ZLIB ################################################
cd $BUILDDIR
tar -zxvf /shared/download/zlib-1.2.11.tar.gz
cd zlib-1.2.11
./configure --prefix=$DIR/grib2
make -j 4
make install


################## COMPILE LIBPNG ################################################
cd $BUILDDIR
tar -zxvf /shared/download/libpng-1.2.57.tar.gz
cd libpng-1.2.57
./configure --prefix=$DIR/grib2
make -j 4
make install


################## COMPILE JASPER ################################################
cd $BUILDDIR
tar -zxvf /shared/download/jasper-1.900.2.tar.gz
cd jasper-1.900.2
./configure --prefix=$DIR/grib2
make -j 4
make install

################## COMPILE WRF    ################################################
cd $DIR
tar -zxvf /shared/download/WRFV3.9.1.1.TAR.gz
cd WRFV3

echo "arch/configure_new.defaults < ${SETUP_DIR}/wrf_configure_new.defaults"
patch arch/configure_new.defaults < ${SETUP_DIR}/wrf_setup_scripts/wrf_configure_new.defaults.patch

#Copy file config.wrf instead of manual configuration
#./configure step with option:
#                   4 dm+sm GCC (gfortran/gcc): Aarch64
#                   1 (basic)
#cp /shared/download/configure.wrf_demo ./configure.wrf
./configure <<@EOF
4
1
@EOF

#Compile in parallel to speed up compilation process
./compile -j 8 em_real >compile.log 2>&1
#Compile in sequence in order to solve unmanaged parallel compilation issues
./compile  em_real >compile.log 2>&1

cd $DIR
ln -s WRFV3 WRFV3-3.9.1.1

################## COMPILE WPS    ################################################
cd $DIR
tar -zxvf /shared/download/WPSV3.9.1.TAR.gz
cd WPS

echo "arch/configure_new.defaults < ${SETUP_DIR}/wrf_configure_new.defaults"
patch arch/configure.defaults < ${SETUP_DIR}/wrf_setup_scripts/wps_configure_new.defaults.patch

#REPLACED WITH STATIC CONFIG FILE
#./configure step with option:
#                   3 (dmpar)

# FIX added option -lgomp to WRF_LIB variable in configure.wps
#cp /shared/download/configure.wps_demo ./configure.wps
./configure <<@EOF
1
@EOF

echo "configure.wps < ${SETUP_DIR}/wrf_setup_scripts"
patch configure.wps < ${SETUP_DIR}/wrf_setup_scripts/configure.wps.patch

#Compile WPS
./compile  >compile.log 2>&1


################## COMPILE ncview  ################################################
cd $BUILDDIR
tar -zxvf /shared/download/ncview-1.93g.tar.gz
cd ncview-1.93g
sudo yum -y install libXaw-devel
./configure --prefix=/shared/gccWRF --with-netcdf_incdir=$NETCDF/include --with-netcdf_libdir=$NETCDF/lib
make
make install
 
################## COMPILE wgrib2  ################################################
cd $BUILDDIR
tar -zxvf /shared/download/wgrib2.tgz
cd grib2
bash <<@EOF
export FC=gfortran
export COMP_SYS=gnu_linux
export CPPFLAGS="-I/shared/gccWRF/netcdf/include/ -I/shared/gccWRF/grib2/include  -L/shared/gccWRF/netcdf/lib/ -L/shared/gccWRF/grib2/lib/"

echo "makefile < ${SETUP_DIR}/wgrib_makefile.patch"
patch --fuzz 3 makefile < ${SETUP_DIR}/wrf_setup_scripts/wgrib_makefile.patch


make
cp wgrib2/wgrib2  $DIR/bin

@EOF

#Wait for Async geog data to complete
wait
