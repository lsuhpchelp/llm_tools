#!/bin/bash

#SBATCH --job-name=llm_inference
#SBATCH --output=/work/**********CHANGEME***************/vllm/logs/llm_inference_%j.out
#SBATCH --error=/work/***********CHANGEME****************/vllm/logs/llm_inference_%j.err
#SBATCH -N 4
#SBATCH --ntasks-per-node=1
#SBATCH --gres=gpu:4
#SBATCH --time=01:00:00
#SBATCH -A ***********CHANGEME****************
#SBATCH -p gpu4



#####**************************************#########
############# CHANGE THESE VARIABLES ###############
# Set environment variables

export SHARED_DIR=/work/$USER/inference/ray
export VLLM_CACHE_DIR=/work/$USER/.cache/vllm
export HF_HOME=${SHARED_DIR}/.cache/huggingface
export MODEL_LOCATION=/work/$USER/models/meta-llama/Meta-Llama-3.1-405B-Instruct
export OUTLINES_CACHE_DIR=/work/$USER/qb4/inference/

module load cuda
module load conda
source /home/$USER/.bashrc

# Activate your conda environment
conda activate vllm-inf

# Get the hostname of the first node (head node)
head_node=$(hostname)
head_node_ip=$(hostname --ip-address)

port=6379

echo "STARTING HEAD at $head_node"
echo "Head node IP: $head_node_ip"
srun --nodes=1 --ntasks=1 -w $head_node start-head.sh $head_node_ip $MODEL_LOCATION &
sleep 15

echo "STARTING WORKERS"
worker_num=$(($SLURM_JOB_NUM_NODES - 1))
srun -n $worker_num --nodes=$worker_num --ntasks-per-node=1 --exclude $head_node start-worker.sh $head_node_ip:$port &

sleep infinity