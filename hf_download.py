import argparse
from huggingface_hub import snapshot_download
import os
from dotenv import load_dotenv


def ensure_base_dir_exists(base_dir):
    if not os.path.exists(base_dir):
        print(f"Base directory {base_dir} does not exist. Creating it now...")
        try:
            os.makedirs(base_dir, exist_ok=True)
            print(f"Created base directory: {base_dir}")
        except Exception as e:
            print(f"Error creating base directory: {e}")
            return False
    return True


def download_model(model_id, base_dir):
    # Ensure the base directory exists
    if not ensure_base_dir_exists(base_dir):
        print("Aborting download due to base directory issues.")
        return

    # Split the model_id into organization and model name
    org_name, model_name = model_id.split("/")

    # Construct the full path for the model
    full_path = os.path.join(base_dir, org_name, model_name)

    # Check if the model already exists
    if os.path.exists(full_path):
        print(f"Model {model_id} already exists at {full_path}")
        return

    print(f"Downloading model {model_id} to {full_path}")

    # Create all necessary directories
    os.makedirs(full_path, exist_ok=True)

    snapshot_download(
        repo_id=model_id,
        local_dir=full_path,
        ignore_patterns=["*.md", "*.pt"],  # Optionally ignore certain file types
    )
    print(f"Download complete. Model saved to {full_path}")


if __name__ == "__main__":
    load_dotenv()
    parser = argparse.ArgumentParser(description="Download a model from Hugging Face.")
    parser.add_argument(
        "model_id",
        type=str,
        help="The model ID in the format 'organization/model_name'",
    )

    # Get the current user's username
    username = os.getenv("USER")

    # Construct the default base directory
    default_base_dir = f"/work/{username}/models"

    parser.add_argument(
        "--base_dir",
        type=str,
        default=default_base_dir,
        help=f"Base directory for model download (default: {default_base_dir})",
    )

    args = parser.parse_args()

    download_model(args.model_id, args.base_dir)
