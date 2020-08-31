#!/bin/bash
#Load Parallelcluster environment variables
. /etc/parallelcluster/cfnconfig

github_repo=$(echo ${cfn_postinstall_args}| cut -d ',' -f 1 )
setup_command=$(echo ${cfn_postinstall_args}| cut -d ',' -f 2 )
shared_folder=$(echo $cfn_shared_dir | cut -d ',' -f 1 )

echo "ARUMENTS $cfn_postinstall_args"
echo "REPO: ${github_repo}"
echo "SETUP COMMAND: ${setup_command}"
echo "SHARED FOLDER: ${shared_folder}"

dir_name=$(basename -s .git ${github_repo})

case ${cfn_node_type} in
        MasterServer)
                echo "I am Master node"
                cd ${shared_folder}
                git clone ${github_repo}
        ;;
        ComputeFleet)
                echo "I am a Compute node"
        ;;
        esac

cd ${shared_folder}/${dir_name}
bash -x ${setup_command} >/tmp/setup.log 2>&1
exit $?