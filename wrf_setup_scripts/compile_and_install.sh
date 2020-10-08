#!/bin/bash
env > /tmp/env_before
source /shared/setup_env.sh

env > /tmp/env_after

#Download source packages
bash download.sh
#Run Manually because it takes too much to be included in cluster preparation
#bash download_and_install_geog_data.sh &

mkdir -p $BUILDDIR
################## COMPILE NETCDF ################################################
cd $BUILDDIR
tar -zxvf /shared/download/netcdf-4.1.3.tar.gz
cd netcdf-4.1.3
./configure --prefix=$DIR/netcdf --disable-dap --disable-netcdf-4 --disable-shared
make -j 4
make install
#

################## COMPILE NETCDF ################################################
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

#Copy file config.wrf instead of manual configuration
#./configure step with option:
#                   35 dm+sm gnu complier
#                   1 (basic)
#cp /shared/download/configure.wrf_demo ./configure.wrf
./configure <<@EOF
35
1
@EOF

#Compile in parallel to speed up compilation process
./compile -j 4 em_real >compile.log 2>&1
#Compile in sequence in order to solve unmanaged parallel compilation issues
./compile  em_real >compile.log 2>&1

cd $DIR
ln -s WRFV3 WRFV3-3.9.1.1

################## COMPILE WPS    ################################################
cd $DIR
tar -zxvf /shared/download/WPSV3.9.1.TAR.gz
cd WPS

#REPLACED WITH STATIC CONFIG FILE
#./configure step with option:
#                   3 (dmpar)

# FIX added option -lgomp to WRF_LIB variable in configure.wps
#cp /shared/download/configure.wps_demo ./configure.wps
./configure <<@EOF
1
@EOF

echp "configure.wps < ${SETUP_DIR}/wrf_setup_scripts"
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
make
cp wgrib2/wgrib2  $DIR/bin

#Wait for Async geog data to complete
wait