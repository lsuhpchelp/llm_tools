Brief overview of the HF parameter efficient fine tuning library (peft)

## Hugging Face PEFT vs Unsloth

PEFT with the accelerate library allows you to train on multiple GPUs, while Unsloth is currently limited to single GPU training in its free version. Unsloth appears to be substantially faster for single GPU training and easier to use. However, with PEFT and accelerate, you can potentially iterate more quickly on your models with access to multiple GPUs.

For example, even if Unsloth is twice as fast on a single GPU, you might achieve faster overall training times using 4 GPUs with PEFT and accelerate.

## Setup

1. **Set up Triton cache directory:**

   ```bash
   export TRITON_CACHE_DIR=/work/$USER/.cache
   mkdir -p $TRITON_CACHE_DIR
   ```

2. **Clone the PEFT repository:**

   ```bash
   git clone https://github.com/huggingface/peft.git
   cd peft/examples/sft
   ```

3. **Set up the Conda environment:**

   Use the provided `peft.yml` file to create your Conda environment:

   ```bash
   conda env create -f peft.yml
   conda activate peft
   ```
   
   > Note: If you plan to experiment with quantization and QLORA, you may need to add the `bitsandbytes` library to your environment:

   ```bash
   conda install -c conda-forge bitsandbytes
   ```

   or

   ```bash
   pip install bitsandbytes
   ```

## Training

For full precision training instructions, refer to the [DeepSpeed documentation on Hugging Face](https://huggingface.co/docs/peft/accelerate/deepspeed). After running `accelerate config --config_file deepspeed_config.yaml`, you will need to select a bunch of options. It's recommended to use Deepspeed ZeRO3 for multiple devices.

Make sure to modify the line in the `.sh` launch file to point to the config file created by this script.

I have only tested with full precision.

## Configuration

### Weights & Biases (WandB) Logging

By default, the training scripts have WandB logging enabled. An example of WandB logging output can be found [here](https://api.wandb.ai/links/killgore-lsu/dnvcrxbc). If you want this, you will need to sign up for a WandB account. After you sign up, you can request a free upgrade to the Academic license, which provides you with the same resources as a Pro license.

### Pushing Models to Hugging Face

The scripts are configured to push models to Hugging Face by default. If you want to keep this enabled you will need to obtain an API key and set the HF_TOKEN environment variable. To disable this, remove the following lines from your training `.sh` file:

```bash
--push_to_hub \
--hub_private_repo True \
--hub_strategy "every_save" \
```

### Using Local Models and Datasets

To use local models and datasets, modify the following lines in your training script to reference a `/work` or `/project` directory on your cluster:

```bash
--model_name_or_path "/path/to/your/local/model" \
--dataset_name "/path/to/your/local/dataset" \
```

## Final Note

[Falcon 180B Finetuning using 🤗 PEFT and DeepSpeed | by Sourab Mangrulkar | Medium](https://medium.com/@sourabmangrulkar/falcon-180b-finetuning-using-peft-and-deepspeed-b92643091d99) 
This guide provides instructions for fine tuning a model on multiple nodes. I have not tested this yet, but wanted to make sure you saw it in case you needed to distribute training across more than one node.


## Links

- [PEFT GitHub Repository](https://github.com/huggingface/peft)
- [DeepSpeed Documentation](https://www.deepspeed.ai/)
- [Hugging Face Transformers](https://huggingface.co/transformers/)

