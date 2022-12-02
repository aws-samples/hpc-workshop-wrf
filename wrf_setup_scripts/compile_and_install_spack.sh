#!/bin/bash


source /shared/setup_env.sh


#Build packages
spack add    wrf@4.4

spack add    wps@4.3

spack add    ncview@4.4

spack install    wgrib2


cat <<@EOF >> /shared/setup_env.sh
spack load wrf
spack load wps
spack load ncview


export WRF_DIR=\$(spack find --path wrf | grep '^wrf' | awk '{print (\$2)'})
export WPS_DIR=\$(spack find --path wps | grep '^wps' | awk '{print (\$2)'})

@EOF

