#!/bin/bash

#SBATCH -J ee628-distributed
#SBATCH -t 0:30:00
#SBATCH --nodes 2
#SBATCH --ntasks-per-node 3
#SBATCH --output=sdistributed.out

# There is a current limitation in pyxis with the entrypoint and it has to run manually.
# It has to run only once per node and the other tasks in the nodes have to wait for it to finish.
# So you can either limit your jobs to 1 task per node or use a sleep command to wait for the entrypoint to finish.


# Variables used by the entrypoint script
# Change this to the path of your project (can be the /dev or /run copy)
export PROJECT_ROOT_AT=$HOME/projects/ee628/run
source $PROJECT_ROOT_AT/installation/docker-arm64-cuda/CSCS-Clariden-setup/ee628-submit-scripts/env-vars.sh $@
export SLURM_ONE_ENTRYPOINT_SCRIPT_PER_NODE=1

srun \
  --container-image=$CONTAINER_IMAGES/$(id -gn)+$(id -un)+ee628+arm64-cuda-root-latest.sqsh \
  --environment="${PROJECT_ROOT_AT}/installation/docker-arm64-cuda/CSCS-Clariden-setup/ee628-submit-scripts/edf.toml" \
  --container-mounts=\
$PROJECT_ROOT_AT,\
$SCRATCH \
  --container-workdir=$PROJECT_ROOT_AT \
  --container-env=PROJECT_NAME,PACKAGE_NAME \
  --no-container-mount-home \
  --no-container-remap-root \
  --no-container-entrypoint \
  --container-writable \
  /opt/template-entrypoints/pre-entrypoint.sh \
  bash -c 'sleep 60; python -m ee628.template_experiment wandb.mode=offline some_arg=LOCALID-$SLURM_LOCALID-PROCID-$SLURM_PROCID'
