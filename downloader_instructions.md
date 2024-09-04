# Model Downloader Instructions

This document explains how to set up and use the Model Downloader script, which allows you to easily download models from Hugging Face to a specified directory on your system.

## Prerequisites

- The `hf.yml` file for creating the conda environment
- The `download.py` script (our Model Downloader script)
- A Hugging Face account and access to the desired model
- Hugging Face API token (for private or gated models)

## Setup

1. **Create and activate the conda environment**

   First, we need to create a conda environment using the provided `hf.yml` file. Open your terminal and run:

   ```bash
   conda env create -f hf.yml
   ```

   This command creates a new conda environment with all the necessary dependencies.

2. **Activate the environment**

   After creation, activate the environment by running:

   ```bash
   conda activate hf
   ```

   You'll need to activate this environment each time you want to use the Model Downloader script.

3. **Set up Hugging Face Authentication**

   - Ensure you have a Hugging Face account and have requested access to the model you want to download (if it's a private or gated model).
   - Get your Hugging Face API token from your account settings on the Hugging Face website.
   - Set the `HF_TOKEN` environment variable with your API token:

     ```bash
     export HF_TOKEN=your_hugging_face_api_token
     ```

   - To make this permanent, add the above line to your `~/.bashrc` or `~/.zshrc` file.

   Note: Setting the `HF_TOKEN` is necessary for downloading private or gated models. Without it, you may encounter authentication errors.

## Using the Model Downloader

Once your environment is set up and activated, you can use the Model Downloader script.

1. **Run the script**

   Use the following command to download a model:

   ```bash
   python download.py organization/model_name
   ```

   Replace `organization/model_name` with the actual model ID you want to download from Hugging Face.

2. **Specify a custom download directory (optional)**

   By default, the script will download models to `/work/$USER/models`, where `$USER` is your username. If you want to use a different directory, you can specify it using the `--base_dir` argument:

   ```bash
   python download.py organization/model_name --base_dir /path/to/custom/directory
   ```

## What the Script Does

The Model Downloader script (`download.py`) performs the following actions:

1. **Sets up the base directory**: 
   - By default, it uses `/work/$USER/models` as the base directory.
   - It checks if this directory exists and creates it if it doesn't.

2. **Parses the model ID**:
   - It splits the provided model ID into organization and model name.

3. **Constructs the full path** for the model:
   - The full path will be `{base_dir}/{organization}/{model_name}`.

4. **Checks for existing downloads**:
   - If the model already exists in the specified path, it skips the download.

5. **Downloads the model**:
   - If the model doesn't exist, it uses the Hugging Face `snapshot_download` function to download the model.
   - It ignores certain file types (like `.md` and `.pt` files) during the download.

6. **Provides feedback**:
   - The script prints information about the download process, including where the model is being saved.

## Troubleshooting

- If you encounter any errors related to missing dependencies, make sure you've activated the correct conda environment (`conda activate hf`).
- If you encounter authentication errors, double-check that you've set the `HF_TOKEN` environment variable correctly and that you have the necessary permissions to access the model on Hugging Face.

Remember to deactivate the conda environment when you're done:

```bash
conda deactivate
```
