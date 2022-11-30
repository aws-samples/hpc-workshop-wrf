#!/bin/bash
env > /tmp/env_before

source /shared/setup_env.sh

env > /tmp/env_after


#Build packages
spack install    wrf@4.2

spack install    wps@4.2

spack install    wgrib2

spack install    ncview@4.2