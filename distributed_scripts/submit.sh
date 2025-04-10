#!/bin/bash

#SBATCH --job-name=llm_inference
#SBATCH --output=/work/killgore/vllm/logs/llm_inference_%j.out
#SBATCH --error=/work/killgore/vllm/logs/llm_inference_%j.err
#SBATCH -N 4
#SBATCH --ntasks-per-node=1
#SBATCH --gres=gpu:2
#SBATCH --time=01:00:00
#SBATCH -A loni_loniadmin1
#SBATCH -p gpu2


# Set environment variables

export SHARED_DIR=/work/$USER/inference/ray
export VLLM_CACHE_DIR=/work/$USER/.cache/vllm
export HF_HOME=${SHARED_DIR}/.cache/huggingface
export OUTLINES_CACHE_DIR=/work/$USER/qb4/inference/


############ Make sure to change this to the model you want to use ############
export MODEL_LOCATION=/work/$USER/models/meta-llama/Meta-Llama-3.1-70B-Instruct
#############################################################################

module load cuda
module load conda
source /home/$USER/.bashrc

# Activate your conda environment
conda activate vllm-inf

# Get the hostname of the first node (head node)
head_node=$(hostname)
head_node_ip=$(hostname --ip-address)

port=6379

# Start the head node
# This runs both Ray and VLLM, with a delay before starting VLLM to ensure Ray is ready
echo "STARTING HEAD at $head_node"
echo "Head node IP: $head_node_ip"
srun --nodes=1 --ntasks=1 -w $head_node start-head.sh $head_node_ip $MODEL_LOCATION &
sleep 15

# Start the Ray workers
echo "STARTING WORKERS"
worker_num=$(($SLURM_JOB_NUM_NODES - 1))
srun -n $worker_num --nodes=$worker_num --ntasks-per-node=1 --exclude $head_node start-worker.sh $head_node_ip:$port &


### Keep the script running indefinitely
### You can also (probably should) put an inference script here
sleep infinity
