#!/bin/bash 
source /shared/setup_env.sh

#Copy WRF Files and links
mkdir -p ${TARGET_DIR}
mkdir -p ${TARGET_DIR}/log

cp -a ${WRF_DIR}/run  ${TARGET_DIR}
cd  ${TARGET_DIR}/run
rm ndown.exe real.exe tc.exe wrf.exe
ln -s  ${WRF_DIR}/main/ndown.exe ndown.exe
ln -s  ${WRF_DIR}/main/real.exe real.exe
ln -s  ${WRF_DIR}/main/tc.exe tc.exe
ln -s  ${WRF_DIR}/main/wrf.exe wrf.exe

#Copy WPS Files and links
mkdir ${TARGET_DIR}/preproc
cd ${TARGET_DIR}/preproc
ln -s ${WPS_DIR}/geogrid.exe geogrid.exe
ln -s ${WPS_DIR}/geogrid/GEOGRID.TBL GEOGRID.TBL
ln -s ${WPS_DIR}/metgrid.exe metgrid.exe
ln -s ${WPS_DIR}/metgrid/METGRID.TBL METGRID.TBL
ln -s ${WPS_DIR}/ungrib.exe ungrib.exe
ln -s ${WPS_DIR}/ungrib/Variable_Tables/Vtable.GFS Vtable

mkdir -p ${SHARED_DIR}/FORECAST/download

cp -R ${SETUP_DIR}/scripts/* ${DIR}/bin
chmod -R 775 ${DIR}/bin
chmod -R 777 ${SHARED_DIR}/FORECAST

