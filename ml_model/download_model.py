"""
Download XLM-RoBERTa model with retry and progress display
"""
import time
from huggingface_hub import snapshot_download

print("=" * 60)
print("Downloading XLM-RoBERTa Model")
print("=" * 60)
print("\nModel: FacebookAI/xlm-roberta-base")
print("Size: ~560 MB")
print("\nThis will download the model files to cache.")
print("Please wait, do not interrupt...")
print("=" * 60)

max_retries = 5
retry_count = 0

while retry_count < max_retries:
    try:
        print(f"\nAttempt {retry_count + 1}/{max_retries}")
        print("Downloading...")
        
        model_path = snapshot_download(
            repo_id="FacebookAI/xlm-roberta-base",
            resume_download=True,
            local_files_only=False
        )
        
        print("\n" + "=" * 60)
        print("✓ DOWNLOAD COMPLETE!")
        print("=" * 60)
        print(f"Model cached at: {model_path}")
        break
        
    except KeyboardInterrupt:
        print("\n\n⚠ Download interrupted by user!")
        print("Please let the download complete...")
        retry_count += 1
        if retry_count < max_retries:
            print(f"Retrying in 3 seconds... ({retry_count}/{max_retries})")
            time.sleep(3)
        else:
            print("Max retries reached. Exiting.")
            exit(1)
            
    except Exception as e:
        print(f"\n⚠ Error: {e}")
        retry_count += 1
        if retry_count < max_retries:
            print(f"Retrying in 5 seconds... ({retry_count}/{max_retries})")
            time.sleep(5)
        else:
            print("Max retries reached. Exiting.")
            exit(1)

print("\n✓ Ready to train! Run: python train_enhanced_xlm.py")
