#!/bin/bash -i
exec 2>/tmp/debug.$$ù
set -x
. /etc/parallelcluster/cfnconfig

shared_folder=$(echo $cfn_ebs_shared_dirs | cut -d ',' -f 1 )


function create_env_file {
echo "Create Env"
cat <<@EOF >${shared_folder}/intel_setup_env.sh
#!/bin/bash
export SHARED_DIR=${shared_folder}
export SETUP_DIR=${shared_folder}/hpc-workshop-wrf
export BUILDDIR=${shared_folder}/build/oneapiWRF
export DIR=${shared_folder}/oneapiWRF
export SCRIPTDIR=${shared_folder}/oneapiWRF/bin

export TARGET_DIR=\${SHARED_DIR}/FORECAST/domains/test.intel/
export GEOG_BASE_DIR=\${SHARED_DIR}/FORECAST/domains/

export WRF_DIR=\$(spack location -i wrf)
export WPS_DIR=\$(spack location -i wps)

export KMP_STACKSIZE=128M
export KMP_AFFINITY=granularity=fine,compact,1,0
export OMP_NUM_THREADS=2

spack env activate wrf-workshop-env
spack load intel-oneapi-mpi
spack load wrf
spack load wps
spack load wgrib2

@EOF

chmod 777 ${shared_folder}
chmod 755 ${shared_folder}/intel_setup_env.sh
rm -f ${shared_folder}/setup_env.sh
ln -s ${shared_folder}/intel_setup_env.sh ${shared_folder}/setup_env.sh
}

function install_spack {
### Install yq
yum install -y wget
if [[ $(uname -m) == "aarch64" ]];then 
   wget -qO /usr/bin/yq https://github.com/mikefarah/yq/releases/download/3.4.1/yq_linux_arm64
else
   wget -qO /usr/bin/yq https://github.com/mikefarah/yq/releases/download/3.4.1/yq_linux_amd64
fi
chmod +x /usr/bin/yq
#########
### Install Spack
yum install -y python3
pip3 install boto3
# Install the latest Spack release
export SPACK_ROOT=/usr/local/spack
mkdir -p $SPACK_ROOT
cd $SPACK_ROOT/..
git clone https://github.com/spack/spack
cd $SPACK_ROOT
git checkout releases/$( \
    git branch -a --list '*releases*'| \
    awk -F '/' 'END{print $NF}')
source $SPACK_ROOT/share/spack/setup-env.sh

echo "export SPACK_ROOT=/share" > /etc/profile.d/spack.sh
echo "source $SPACK_ROOT/share/spack/setup-env.sh" >> /etc/profile.d/spack.sh

cat> /etc/profile.d/spack-env.sh << END
# Make the spack command available to the shell
source $SPACK_ROOT/share/spack/setup-env.sh
END
mkdir -p $SPACK_ROOT/var/spack/environments/aws
### Download aws env file
wget https://gist.githubusercontent.com/bollig/71383f92143ed6b006e5c3892343fef8/raw/2_spack.yaml -O $SPACK_ROOT/var/spack/environments/aws/spack.yaml
### Usersetup
source /etc/os-release 
if [[ $ID == "centos" ]];then
  chown -R centos: /usr/local/spack /fsx/spack
elif [[ $ID == "amzn" ]];then
  chown -R ec2-user: /usr/local/spack /fsx/spack
fi

### Change config
export SPACK_SHARED=/shared/spack
yq w -i /usr/local/spack/etc/spack/defaults/config.yaml config.module_roots.lmod ${SPACK_SHARED}/lmod
yq w -i /usr/local/spack/etc/spack/defaults/config.yaml config.module_roots.tcl ${SPACK_SHARED}/modules
yq w -i /usr/local/spack/etc/spack/defaults/config.yaml config.install_tree.root ${SPACK_SHARED}/opt/spack

}

echo "NODE TYPE: ${cfn_node_type}"

case ${cfn_node_type} in
        HeadNode)
                echo "I am the HeadNode node"
                
                
                create_env_file
                source ${shared_folder}/setup_env.sh
                cd wrf_setup_scripts
                /bin/su ec2-user -c "/bin/bash -i compile_and_install_intel.sh"
                /bin/su ec2-user -c "/bin/bash -i build_dir.sh"

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