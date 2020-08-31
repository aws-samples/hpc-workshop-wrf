#!/bin/bash
source /shared/setup_env.sh

cd ${SHARED_DIR}/download
wget --no-check-certificate https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_complete.tar.gz

#Copy geog data
mkdir -p ${GEOG_BASE_DIR}
cd  ${GEOG_BASE_DIR}
tar -zxvf ${SHARED_DIR}/download/geog_complete.tar.gz