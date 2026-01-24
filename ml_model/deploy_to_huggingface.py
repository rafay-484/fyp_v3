"""
Quick script to deploy your model to Hugging Face
Run this after you've logged in with: huggingface-cli login
"""

from huggingface_hub import HfApi, create_repo
import os

def deploy_model(username, repo_name="urdu-punjabi-classifier"):
    """
    Deploy the trained model to Hugging Face Hub
    
    Args:
        username: Your Hugging Face username
        repo_name: Name for your model repository
    """
    api = HfApi()
    
    # Create repository
    repo_id = f"{username}/{repo_name}"
    print(f"Creating repository: {repo_id}")
    
    try:
        create_repo(repo_id=repo_id, repo_type="model", exist_ok=True)
        print(f"✓ Repository created/exists: https://huggingface.co/{repo_id}")
    except Exception as e:
        print(f"Repository creation: {e}")
    
    # Upload model files
    model_path = "trained_model/xlm_roberta_urdu_punjabi"
    
    if not os.path.exists(model_path):
        print(f"❌ Model not found at {model_path}")
        print("Please train the model first!")
        return
    
    print(f"\nUploading model from {model_path}...")
    print("This may take a few minutes...")
    
    try:
        api.upload_folder(
            folder_path=model_path,
            repo_id=repo_id,
            repo_type="model"
        )
        print(f"\n✓ Model uploaded successfully!")
        print(f"\n🎉 Your model is live at: https://huggingface.co/{repo_id}")
        print(f"\n📡 API endpoint: https://api-inference.huggingface.co/models/{repo_id}")
        
    except Exception as e:
        print(f"❌ Upload failed: {e}")
        print("\nMake sure you've logged in with: huggingface-cli login")

if __name__ == "__main__":
    print("=" * 60)
    print("  Hugging Face Model Deployment")
    print("=" * 60)
    print()
    
    # Get username
    username = input("Enter your Hugging Face username: ").strip()
    
    if not username:
        print("❌ Username required!")
        exit(1)
    
    print()
    deploy_model(username)
    
    print("\n" + "=" * 60)
    print("Next step: Update your Flutter app with the API endpoint!")
    print("=" * 60)
