#!/bin/bash

#SBATCH -J ee628-run-dist
#SBATCH -t 12:00:00
#SBATCH -A a-a10
#SBATCH --output=sunattended-ds-zero1.out
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1

# Variables used by the entrypoint script
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
  --no-container-mount-home \
  --no-container-remap-root \
  --no-container-entrypoint \
  --container-writable \
  /opt/template-entrypoints/pre-entrypoint.sh \
  bash -c "exec accelerate launch --config-file src/ee628/configs/accelerate/ds-zero1.yaml \
  --num_machines $SLURM_NNODES \
  --num_processes $((4*$SLURM_NNODES)) \
  --main_process_ip $(hostname) \
  --machine_rank \$SLURM_NODEID \
  $*"
