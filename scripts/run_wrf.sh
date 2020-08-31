#!/bin/bash
source /shared/setup_env.sh
cd /shared/FORECAST/domains/test/run
echo "#################################"
env
echo "#################################"
cat $PE_HOSTFILE
echo "#################################"
for host in $(cat $PE_HOSTFILE | awk '{print $1}')
do
        hostlist="$hostlist,$host"
done
echo $hostlist
echo "#################################"

#Each process uses 2 threads and only phisical cores
let PROCESS=NSLOTS/2
PPN=18                 #c5n.18xlarge
unset PE_HOSTFILE
export OMP_NUM_THREADS=2
echo "Processes $PROCESS"
time mpirun -np $PROCESS -host $hostlist -ppn 18 ./wrf.exe
