#!/bin/bash
###################################################################################
# Setup Environmen Variable
###################################################################################
source /shared/setup_env.sh

ulimit -s unlimited

NP=$(ls /sys/class/cpuid/ | wc -l)

NP=$(( $NP / 2 ))


day=$(date +%Y%m%d)

WPSWORK=${TARGET_DIR}/preproc
WRFWORK=${TARGET_DIR}/run

DIRGFS=${SHARED_DIR}/FORECAST/download/$day
###################################################################################
# Print log function
###################################################################################
log ()
{
        timestamp=`date "+%Y.%m.%d-%H:%M:%S %Z"`
        echo "$timestamp $*"
}

###################################################################################
# Start Preprocessing
###################################################################################
cd $WPSWORK
log "INFO - Starting geogrid.exe"
./geogrid.exe > geogrid.$day.log 2>&1
if [ $? -ne 0 ]
then
        log "CRIT - geogrid.exe Completed with errors."
        exit 1
fi
log "INFO - geogrid.exe Completed"

cd $DIRGFS
cp -f GRIBFILE* $WPSWORK
cd $WPSWORK


rm -f FILE*
rm -f PFILE*


log "INFO - Starting ungrib.exe"
./ungrib.exe > ungrib.$day.log 2>&1
if [ $? -ne 0 ]
then
        log "CRIT - ungrib.exe Completed with errors."
        exit 1
fi

log "INFO - ungrib.exe Completed"

rm -f met_em*

log "INFO - Starting metgrid.exe"
#mpirun -np $NP ./metgrid.exe > metgrid.$day.log 2>&1
./metgrid.exe > metgrid.$day.log 2>&1
if [ $? -ne 0 ]
then
        log "CRIT - metgrid.exe Completed with errors."
        exit 1
fi
log "INFO - metgrid.exe Completed"


mv met_em* $WRFWORK

###################################################################################
# Start WRF Processing
###################################################################################

cd $WRFWORK

rm -f rsl.*
rm -f wrfinput*
rm -f wrfbdy*
rm -f wrfout*


log "INFO - Starting real.exe"
#mpirun -np $NP ./real.exe  >real.$day.log 2>&1
./real.exe >real.$day.log 2>&1
if [ $? -ne 0 ]
then
        log "CRIT - real.exe Completed with errors."
        exit 1
fi
log "INFO - real.exe Completed"



exit 0
