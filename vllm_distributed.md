# How to Use VLLM on GPU Nodes
This guide will walk you through the process of setting up and using VLLM across multiple GPU nodes using Ray. VLLM will distribute the model across multiple GPUs using tensor parallelism and/or pipeline parallelism. For a single node, tensor parallelism is more efficient.

## Steps

### 1. Prepare the Environment
1. Ensure you are on a GPU node, then load the CUDA and Conda modules:
   ```bash
   module load cuda
   module load conda
   ```
2. Create a Conda virtual environment with Python 3.10:
   ```bash
   conda create -n vllm-inf python=3.10 -y
   ```
3. Activate the Conda environment:
   ```bash
   conda activate vllm-inf
   ```
4. Create necessary directories
   ```bash
   mkdir -p /work/$USER/inference/ray
   mkdir -p /work/$USER/.cache/vllm
   mkdir -p /work/$USER/qb4/inference
   mkdir -p /work/$USER/vllm/logs
   ```

### 2. Install VLLM
1. Check for the latest VLLM tag on [GitHub](https://github.com/vllm-project/vllm). For the purposes of this guide, we will use version 0.5.5.
2. Install the nightly release of VLLM using the following commands:
   ```bash
   export VLLM_VERSION=0.5.5
   pip install https://vllm-wheels.s3.us-west-2.amazonaws.com/nightly/vllm-${VLLM_VERSION}-cp38-abi3-manylinux1_x86_64.whl
   ```
   > Note: The nightly release is required due to an issue with the `outlines` library.

### 3. Install Ray
Install Ray using pip:
```bash
pip install ray
```

### 4. Configure Cache Directories
Set up the necessary cache directories:
```bash
export SHARED_DIR=/work/$USER/inference/ray
export VLLM_CACHE_DIR=/work/$USER/.cache/vllm
export HF_HOME=${SHARED_DIR}/.cache/huggingface
export OUTLINES_CACHE_DIR=/work/$USER/qb4/inference/
mkdir -p $SHARED_DIR $VLLM_CACHE_DIR $OUTLINES_CACHE_DIR
```

### 5. Obtain the Model

> Note: See the downloader_instructions.md and hf_download.py files for download instructions and a convenience script.

Either download the model from Hugging Face, using the script, or use one that you have trained yourself. Make sure it is in a directory that the GPU nodes can access. For example:
```bash
export MODEL_LOCATION=/work/$USER/models/meta-llama/Meta-Llama-3.1-405B-Instruct
```

### 6. Download the Scripts
The necessary scripts are provided in the LSU HPC GitHub repository. Follow these steps to download them:

1. If you don't have Git installed, install it:
   ```bash
   conda install git -y
   ```

2. Clone the repository:
   ```bash
   git clone https://github.com/lsuhpchelp/llm_tools.git
   cd llm_tools
   ```

3. Navigate to the distributed scripts directory:
   ```bash
   cd vllm_dist
   ```

4. Ensure you have the necessary permissions to execute these scripts:
   ```bash
   chmod +x start-head.sh start-worker.sh submit.sh
   ```

### 7. Configure the Scripts
Before submitting the job, you may need to modify the `submit.sh` script to match your specific requirements. Open the file in a text editor and check the following:

- Ensure the `#SBATCH` directives match your resource needs (number of nodes, GPUs, time limit, etc.).
- Verify that the path to the model (`MODEL_LOCATION`) is correct.
- Check that the conda environment name (`vllm-inf`) matches the one you created.
- Update the log file paths to use the new directory:
  ```bash
  #SBATCH --output=/work/$USER/vllm/logs/llm_inference_%j.out
  #SBATCH --error=/work/$USER/vllm/logs/llm_inference_%j.err
  ```
- Make sure to create the log directory:
  ```bash
  mkdir -p /work/$USER/vllm/logs
  ```

### 8. Submit the Job
Use the following command to submit the job:
```bash
sbatch submit.sh
```

### 9. Monitor the Job
You can monitor the job using the `squeue` command:
```bash
squeue -u $USER
```

### 10. Connect to the Model
You can connect to the model using Langchain or OpenAI-compatible API tools. You will need a separate conda environment with langchain and lanchain_community installed. If you're using Jupyter, that environment will also need ipykernel. Here's an example using Python:

> It's very important that the model name match the one that you are serving. If there is a "/" at the end of the model name in the serve command, it must be included in the model name in the Python code.

```python
import multiprocessing
from langchain_community.chat_models import ChatLlamaCpp
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(temperature=0.5,
                 model="/work/$USER/models/meta-llama/Meta-Llama-3.1-405B-Instruct", 
                 openai_api_base="http://<IP.OF.HEAD.NODE>:8000/v1", 
                 openai_api_key="n/a",
                 max_tokens=100000)

# Example usage:
for chunk in llm.stream("""Write a python function that recursively writes new python functions."""):
    print(chunk.content, end="", flush=True)
```



## Additional Notes
- The scripts provided in the GitHub repository are designed to work with the LSU HPC environment. If you're using a different HPC system, you may need to adjust the scripts accordingly.
- Always refer to the latest documentation in the GitHub repository for any updates or changes to the process.
- If you need to update the VLLM version, make sure to check for compatibility with your model and other dependencies.
- The log files for your job will be located in `/work/$USER/vllm/logs/`. Make sure to check this directory for any output or error messages from your job.