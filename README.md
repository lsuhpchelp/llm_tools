# Model Training and Inference Repository

This repository contains scripts and configuration files for downloading, fine-tuning, and serving large language models using various tools and libraries.

## Contents

1. **Model Downloader**
   - `hf_download.py`: Script for downloading models from Hugging Face
   - `hf.yml`: Conda environment file for the model downloader

2. **Fine-tuning with PEFT**
   - `peft_lora_deepspeed.md`: Instructions for using the Hugging Face PEFT library with LoRA and DeepSpeed
   - `peft.yml`: Conda environment file for PEFT fine-tuning

3. **Model Serving with VLLM**
   - `vllm_instructions.md`: Guide for setting up and using VLLM on a GPU node

4. **Environment Files**
   - `hf.yml`: Conda environment for Hugging Face related tasks
   - `peft.yml`: Conda environment for PEFT and fine-tuning tasks

## Setup

1. Clone this repository
2. Create the necessary Conda environments using the provided `.yml` files
3. Follow the instructions in the respective markdown files for each task

## Usage

### Downloading Models
Use the `hf_download.py` script to download models from Hugging Face. See `downloader_instructions.md` for detailed usage.

### Fine-tuning Models
Refer to `peft_lora_deepspeed.md` for instructions on fine-tuning models using PEFT, LoRA, and DeepSpeed.

### Serving Models
Follow the guide in `vllm_instructions.md` to set up and use VLLM for serving models on GPU nodes.

### Other Info 
 - Hugging Face API key required for some portions of the instructions.
 - Weights and Biases API key required for experiment tracking in the fine-tuning section.
