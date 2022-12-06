#!/bin/bash
source /shared/setup_env.sh

cd ${shared_folder}/hpc-workshop-wrf/wrf_setup_scripts

bash download_and_install_geog_data.sh &

bash compile_and_install_using_spack.sh

bash build_dir.sh
