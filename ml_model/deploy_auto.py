"""
Automated deployment script - no input required
"""

from huggingface_hub import HfApi, create_repo
import os

def deploy_model_auto():
    username = "RAFAY-484"
    repo_name = "urdu-punjabi-classifier"
    api = HfApi()
    
    repo_id = f"{username}/{repo_name}"
    print(f"Creating repository: {repo_id}")
    
    try:
        create_repo(repo_id=repo_id, repo_type="model", exist_ok=True)
        print(f"✓ Repository created/exists: https://huggingface.co/{repo_id}")
    except Exception as e:
        print(f"Repository creation: {e}")
    
    model_path = "trained_model/xlm_roberta_urdu_punjabi"
    
    if not os.path.exists(model_path):
        print(f"❌ Model not found at {model_path}")
        return False
    
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
        return True
        
    except Exception as e:
        print(f"❌ Upload failed: {e}")
        return False

if __name__ == "__main__":
    print("=" * 60)
    print("  Automated Deployment - RAFAY-484")
    print("=" * 60)
    print()
    deploy_model_auto()
