#!/bin/bash

#SBATCH -J ee628-dev
#SBATCH -t 4:00:00
#SBATCH -p debug
#SBATCH -A a-a10
#SBATCH --output=sremote-development.out
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1

# Variables used by the entrypoint script
export PROJECT_ROOT_AT=$HOME/projects/ee628/dev
source $PROJECT_ROOT_AT/installation/docker-arm64-cuda/CSCS-Clariden-setup/ee628-submit-scripts/env-vars.sh $@
export SLURM_ONE_ENTRYPOINT_SCRIPT_PER_NODE=1
export SLURM_ONE_REMOTE_DEV=1
export SSH_SERVER=1
export NO_SUDO_NEEDED=1
mkdir -p $HOME/jetbrains-server/dist
export JETBRAINS_SERVER_AT=$HOME/jetbrains-server
mkdir -p $HOME/vscode-server
export VSCODE_SERVER_AT=$HOME/vscode-server

# If you have a PyCharm IDE
export PYCHARM_IDE_AT=a72a92099e741_pycharm-professional-2024.3.3-aarch64
# You can get one with
# mkdir -p $HOME/jetbrains-server/dist
# cp -r /capstor/store/cscs/swissai/a10/pycharm-dists/a72a92099e741_pycharm-professional-2024.3.3-aarch64 $HOME/jetbrains-server/dist/

srun \
  --container-image=$CONTAINER_IMAGES/$(id -gn)+$(id -un)+ee628+arm64-cuda-root-latest.sqsh \
  --environment="${PROJECT_ROOT_AT}/installation/docker-arm64-cuda/CSCS-Clariden-setup/ee628-submit-scripts/edf.toml" \
  --container-mounts=\
$PROJECT_ROOT_AT,\
$SCRATCH,\
$HOME/.gitconfig,\
$HOME/.bashrc,\
$JETBRAINS_SERVER_AT,\
$VSCODE_SERVER_AT,\
$HOME/.ssh \
  --container-workdir=$PROJECT_ROOT_AT \
  --no-container-mount-home \
  --no-container-remap-root \
  --no-container-entrypoint \
  --container-writable \
  /opt/template-entrypoints/pre-entrypoint.sh \
  sleep infinity

# Here can connect to the container with
# 1. SSH
# ssh clariden-container
#
# 2. By execing a shell
# Get the job id (and node id if multinode)
#
# Connect to the allocation
#   srun --overlap --pty --jobid=JOBID bash
# Inside the job find the container name
#   enroot list -f
# Exec to the container
#   enroot exec <container-pid> zsh
