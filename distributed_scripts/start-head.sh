#!/bin/bash

# Create necessary directories
mkdir -p /work/$USER/inference/ray
mkdir -p /work/$USER/.cache/vllm
mkdir -p /work/$USER/qb4/inference
mkdir -p /work/$USER/vllm/logs

export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export SHARED_DIR=/work/$USER/inference/ray
export VLLM_CACHE_DIR=/work/$USER/.cache/vllm
export HF_HOME=${SHARED_DIR}/.cache/huggingface
export OUTLINES_CACHE_DIR=/work/$USER/qb4/inference/

module load cuda
module load conda
source /home/$USER/.bashrc

# Activate your conda environment
conda activate vllm-inf

echo "starting ray head node"
# Launch the head node
ray start --head --node-ip-address=$1 --port=6379 --block &
sleep 20
vllm serve $2 -tp 16&
sleep infinity