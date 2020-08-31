#!/bin/bash -i
. /etc/parallelcluster/cfnconfig

shared_folder=$(echo $cfn_shared_dir | cut -d ',' -f 1 )


function create_env_file {
echo "Create Env"
cat <<@EOF >${shared_folder}/intel_setup_env.sh
#!/bin/bash
export SHARED_DIR=${shared_folder}
export SETUP_DIR=${shared_folder}/hpc-workshop-wrf
export BUILDDIR=${shared_folder}/build/oneapiWRF
export DIR=${shared_folder}/oneapiWRF
export SCRIPTDIR=${shared_folder}/oneapiWRF/bin
#Compiler Specific iCC
export CC=icc
export CXX=icpc
export CFLAGS='-O3 -xHost -ip -no-prec-div -static-intel'
export CXXFLAGS='-O3 -xHost -ip -no-prec-div -static-intel'
export F77=ifort
export FC=ifort
export F90=ifort
export FFLAGS='-O3 -xHost -ip -no-prec-div -static-intel'
export CPP='icc -E'
export CXXCPP='icpc -E'

export JASPERLIB=${shared_folder}/oneapiWRF/grib2/lib
export JASPERINC=${shared_folder}/oneapiWRF/grib2/include
export LDFLAGS=-L${shared_folder}/oneapiWRF/grib2/lib
export CPPFLAGS=-I${shared_folder}/oneapiWRF/grib2/include
export PATH=${shared_folder}/oneapiWRF/netcdf/bin:${shared_folder}/oneapiWRF/bin:\$PATH
export NETCDF=${shared_folder}/oneapiWRF/netcdf
export JASPERLIB=${shared_folder}/oneapiWRF/grib2/lib
export JASPERINC=${shared_folder}/oneapiWRF/grib2/include
export TARGET_DIR=\${SHARED_DIR}/FORECAST/domains/test.intel/
export GEOG_BASE_DIR=\${SHARED_DIR}/FORECAST/domains/
export WRF_DIR=\${DIR}/WRFV3-3.9.1.1
export WPS_DIR=\${DIR}/WPS
export KMP_STACKSIZE=128M
export KMP_AFFINITY=granularity=fine,compact,1,0
export OMP_NUM_THREADS=2

module unload intelmpi

module load intelmpi

source /opt/intel/oneapi/setvars.sh
@EOF

chmod 777 ${shared_folder}
chmod 755 ${shared_folder}/intel_setup_env.sh
rm -f ${shared_folder}/setup_env.sh
ln -s ${shared_folder}/intel_setup_env.sh ${shared_folder}/setup_env.sh
}

function install_intel_onepi_beta {
echo "Installing Intel ONEAPI BETA"     
#Install Intel OpenAPI Compiler
cat > /tmp/oneAPI.repo << EOF
[oneAPI]
name=Intel(R) oneAPI repository
baseurl=https://yum.repos.intel.com/oneapi
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2023.PUB
EOF

sudo mv /tmp/oneAPI.repo /etc/yum.repos.d

yum -y install intel-hpckit
}

echo "NODE TYPE: ${cfn_node_type}"

case ${cfn_node_type} in
        MasterServer)
                echo "I am Master node"
                create_env_file
                install_intel_onepi_beta
        ;;
        ComputeFleet)
                echo "I am a Compute node"
        ;;
        esac

# Set ulimits according to WRF needs
cat >>/tmp/limits.conf << EOF
# core file size (blocks, -c) 0
*           hard    core           0
*           soft    core           0

# data seg size (kbytes, -d) unlimited
*           hard    data           unlimited
*           soft    data           unlimited

# scheduling priority (-e) 0
*           hard    priority       0
*           soft    priority       0

# file size (blocks, -f) unlimited
*           hard    fsize          unlimited
*           soft    fsize          unlimited

# pending signals (-i) 256273
*           hard    sigpending     1015390
*           soft    sigpending     1015390

# max locked memory (kbytes, -l) unlimited
*           hard    memlock        unlimited
*           soft    memlock        unlimited

# open files (-n) 1024
*           hard    nofile         65536
*           soft    nofile         65536

# POSIX message queues (bytes, -q) 819200
*           hard    msgqueue       819200
*           soft    msgqueue       819200

# real-time priority (-r) 0
*           hard    rtprio         0
*           soft    rtprio         0

# stack size (kbytes, -s) unlimited
*           hard    stack          unlimited
*           soft    stack          unlimited

# cpu time (seconds, -t) unlimited
*           hard    cpu            unlimited
*           soft    cpu            unlimited

# max user processes (-u) 1024
*           soft    nproc          16384
*           hard    nproc          16384

# file locks (-x) unlimited
*           hard    locks          unlimited
*           soft    locks          unlimited
EOF

sudo bash -c 'cat /tmp/limits.conf > /etc/security/limits.conf'
exit 0
