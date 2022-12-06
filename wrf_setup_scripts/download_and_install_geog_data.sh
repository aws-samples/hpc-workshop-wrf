#!/bin/bash
source /shared/setup_env.sh

cd ${SHARED_DIR}/download
wget --no-check-certificate https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_complete.tar.gz  -q
wget --no-check-certificate https://www2.mmm.ucar.edu/wrf/src/wps_files/albedo_modis.tar.bz2  -q
wget --no-check-certificate https://www2.mmm.ucar.edu/wrf/src/wps_files/maxsnowalb_modis.tar.bz2  -q

#Copy geog data
mkdir -p ${GEOG_BASE_DIR}
cd  ${GEOG_BASE_DIR}
tar -zxvf ${SHARED_DIR}/download/geog_complete.tar.gz
cd  ${GEOG_BASE_DIR}/geog
bzip2 -dc ${SHARED_DIR}/download/albedo_modis.tar.bz2 | tar -xf -
bzip2 -dc ${SHARED_DIR}/download/maxsnowalb_modis.tar.bz2 | tar -xf -