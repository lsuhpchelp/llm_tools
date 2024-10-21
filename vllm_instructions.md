# How to Use VLLM on a GPU Node

This guide will walk you through the process of setting up and using VLLM. VLLM will distribute the model across multiple GPUs using tensor parallelism and/or pipeline parallelism. For a single node, tensor parallelism is more efficient.

If your model is significantly smaller than the GPU memory, VLLM will load your model into the GPU as many times as necessary to fill the GPU memory. This can allow you to process more data in parallel using asynchronous requests or multiprocessing.

## Steps

### 1. Prepare the Environment

1. Ensure you are on a GPU node, then load the CUDA module:

   ```bash
   module load cuda
   ```

2. Create a Conda virtual environment with Python 3.10:
   ```bash
   conda create -n vllm-inf python=3.10 -y
   ```
3. Activate the Conda environment:
   ```bash
   conda activate vllm-inf
   ```

### 2. Install VLLM

Install VLLM with pip
```bash
pip install vllm
```

### 3. Configure Outlines Cache Directory

Set the Outlines cache directory (and make sure it exists):
```bash
export OUTLINES_CACHE_DIR=/work/killgore/.cache/outlines

mkdir -p $OUTLINES_CACHE_DIR
```

### 4. Obtain the Model
Either download the model from huggingface or use one that you have trained yourself. Make sure it is in a directory that the GPU node can access.

If using the downloader script provided in a separate file, the model will be at the following location:
```bash
/work/$USER/models/<organization>/<model_name>

# Example:
/work/killgore/models/meta-llama/Meta-Llama-3.1-70B-Instruct

```

### 5. Serve the Model

Use the following command to serve the model:
```bash
vllm serve /work/killgore/models/meta-llama/Meta-Llama-3.1-70B-Instruct --tensor-parallel-size 4
```
> Tensor parallelism is used to distribute the model across multiple GPUs. The `--tensor-parallel-size` flag specifies the number of GPUs to use.

### 6. Connect to the Model

You can connect to the model using Langchain or OpenAI-compatible API tools. You will need a separate conda environment with langchain and lanchain_community installed. If you're using Jupyter, that environment will also need ipykernel. Here's an example using Python:

> It's very important that the model name match the one that you are serving. If there is a "/" at the end of the model name, in the serve command, it must be included in the model name in the Python code.

```python
import multiprocessing
from langchain_community.chat_models import ChatLlamaCpp
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(temperature=0.5,
                 model="/work/killgore/models/meta-llama/Meta-Llama-3.1-70B-Instruct", 
                 openai_api_base="http://localhost:8000/v1", 
                 openai_api_key="n/a",
                 max_tokens=100000)

# Example usage:
for chunk in llm.stream("""Write a python function that recursively writes new python functions."""):
    print(chunk.content, end="", flush=True)
```
