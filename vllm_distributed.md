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
   mkdir -p /work/$USER/inference
   mkdir -p /work/$USER/vllm/logs
   ```

### 2. Install VLLM

Install VLLM with pip
```bash
pip install vllm
```

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
export OUTLINES_CACHE_DIR=/work/$USER/inference/
mkdir -p $SHARED_DIR $VLLM_CACHE_DIR $OUTLINES_CACHE_DIR
```

### 5. Obtain the Model

> Note: See the downloader_instructions.md and hf_download.py files for download instructions and a convenience script.

Either download the model from Hugging Face, use the script mentioned above, or use one that you have trained yourself. Make sure it is in a directory that the GPU nodes can access. For example:

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
   cd distributed_scripts
   ```

4. Ensure you have the necessary permissions to execute these scripts:
   ```bash
   chmod +x start-head.sh start-worker.sh submit.sh
   ```

### 7. Configure the Scripts

Before submitting the job, you may need to modify the `submit.sh` script to match your specific requirements. Open the file in a text editor and check the following:

- Ensure the `#SBATCH` directives match your resource needs (number of nodes, GPUs, time limit, etc.).
- In the `start-head.sh` file, on the line that starts VLLM, you can modify tensor and pipeline parallelism.
  - Tensor parallelism flag: `--tp <##>`
  - Pipeline parallesm flag: `--pp <##>`
  - **The current script is configured with `--tp 16`, which uses full tensor parallelism across 16 GPUs. If you change it, pipeline parallelism should be the number of nodes, and tensor parallelism should be the number of GPUs per node.**
- To estimate GPU memory needs of a model, the easiest method is to multiply the number of parameters by the number of bits in each parameter.
  - EXAMPLE: 70B parameter model @ 16 bit precision
    - 1B translates to `Giga`
    - 8 bits in 1 Byte
    - 2 Bytes per parameter @ 16 bit precision
    - 2 Bytes \* 70B = 140 GigaBytes
    - **The model still needs additional memory for context** and likely won't run on 2 80GB GPUs. Since the nodes are available in multiples of 2, use 4x80GB GPUs for a 70B Model
  - EXAMPLE 2: 405B parameter model @ 16 bit precision
    - 2 Bytes \* 405B = 810 GigaBytes = minimum of 11x80GB GPUs without accounting for context
    - Recommend using 16 A100 80GB GPUs (4x4 GPU nodes) to ensure it fits

- Verify that the path to the model (`MODEL_LOCATION`) is correct.
- Check that the conda environment name (`vllm-inf`) matches the one you created.
- Update the log file paths to use the new directory:
  ```bash
  #SBATCH --output=/work/$USER/vllm/logs/llm_inference_%j.out
  #SBATCH --error=/work/$USER/vllm/logs/llm_inference_%j.err
  ```
- Make sure to create the log directory if it is different from the above:
  ```bash
  mkdir -p /work/$USER/vllm/logs
  ```
- modify the tensor and pipeline parallelism

### 8. Submit the Job

Use the following command to submit the job:

```bash
sbatch submit.sh
```

### 9. Monitor the Job

You can monitor the status of loading the model by reviewing the output and error logs shows in step 8.

### 10. Connect to the Model

You can connect to the model using Langchain or OpenAI-compatible API tools. You will need a separate conda environment with langchain and lanchain_community installed. If you're using Jupyter, that environment will also need ipykernel. Below is an example using Python.

> It's very important that the model name match the one that you are serving. If there is a "/" at the end of the model name in the serve command, it must be included in the model name in the Python code.

If you need an interactive environment, you can start a new Jupyter session on Open OnDemand using the `single` queue, 1 node and 1 cpu to test inferencing. For larger jobs, once you have finished testing it's best to put your code at the end of the submit.sh file.

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

- The log files for your job will be located in `/work/$USER/vllm/logs/`. Make sure to check this directory for any output or error messages from your job.
