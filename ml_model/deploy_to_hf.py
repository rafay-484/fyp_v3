"""
Deploy trained model to Hugging Face Hub
"""

from huggingface_hub import HfApi, login
import os

print("=" * 70)
print("🤗 HUGGING FACE MODEL DEPLOYMENT")
print("=" * 70)

# Step 1: Login
print("\n📝 Step 1: Login to Hugging Face")
print("-" * 70)
print("You need a Hugging Face access token.")
print("Get it from: https://huggingface.co/settings/tokens")
print("(Create a new token with 'Write' permissions)")
print("-" * 70)

token = input("\n🔑 Paste your Hugging Face token here: ").strip()

if not token:
    print("❌ No token provided. Exiting.")
    exit(1)

try:
    login(token=token)
    print("✅ Successfully logged in to Hugging Face!")
except Exception as e:
    print(f"❌ Login failed: {e}")
    exit(1)

# Step 2: Get username and repo name
print("\n📝 Step 2: Configure Repository")
print("-" * 70)
username = input("Enter your Hugging Face username: ").strip()
repo_name = input("Enter model repository name (e.g., 'urdu-punjabi-classifier'): ").strip() or "urdu-punjabi-classifier"

repo_id = f"{username}/{repo_name}"
print(f"\n📦 Will upload to: {repo_id}")

# Step 3: Upload model
print("\n📝 Step 3: Uploading Model")
print("-" * 70)

model_path = os.path.join(os.path.dirname(__file__), "trained_model", "xlm_roberta_urdu_punjabi")

if not os.path.exists(model_path):
    print(f"❌ Model not found at: {model_path}")
    print("Make sure you have trained the model first!")
    exit(1)

print(f"📂 Model path: {model_path}")
print("⏳ Creating repository and uploading... (this may take several minutes)")

try:
    api = HfApi()
    
    # Create the repository first
    print("📦 Creating repository...")
    api.create_repo(
        repo_id=repo_id,
        repo_type="model",
        exist_ok=True,
        private=False
    )
    print("✅ Repository created!")
    
    # Upload the model
    print("⏳ Uploading model files...")
    api.upload_folder(
        folder_path=model_path,
        repo_id=repo_id,
        repo_type="model",
        commit_message="Upload XLM-RoBERTa Urdu/Punjabi classifier"
    )
    print(f"\n✅ Model uploaded successfully!")
    print(f"🔗 View at: https://huggingface.co/{repo_id}")
except Exception as e:
    print(f"❌ Upload failed: {e}")
    exit(1)

# Step 4: Create Gradio Space
print("\n" + "=" * 70)
print("📝 Step 4: Create Hugging Face Space (Optional)")
print("=" * 70)
print("\nTo create an interactive demo:")
print(f"1. Go to: https://huggingface.co/spaces")
print(f"2. Click 'Create new Space'")
print(f"3. Name: {repo_name}-demo")
print(f"4. SDK: Gradio")
print(f"5. Create these files in your Space:")
print("\n--- app.py ---")

app_py = f'''import gradio as gr
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch

MODEL_NAME = "{repo_id}"

print(f"Loading model: {{MODEL_NAME}}")
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
model = AutoModelForSequenceClassification.from_pretrained(MODEL_NAME)
model.eval()
print("Model loaded successfully!")

def detect_language(text):
    """Detect if text is Urdu or Punjabi"""
    if not text or not text.strip():
        return {{
            "error": "Please enter some text",
            "language": None,
            "confidence": 0
        }}
    
    inputs = tokenizer(
        text,
        return_tensors="pt",
        truncation=True,
        max_length=128,
        padding=True
    )
    
    with torch.no_grad():
        outputs = model(**inputs)
        probs = torch.softmax(outputs.logits, dim=1)
        predicted_class = torch.argmax(probs, dim=1).item()
        confidence = probs[0][predicted_class].item()
    
    language = "urdu" if predicted_class == 0 else "punjabi"
    
    return {{
        "language": language,
        "confidence": round(confidence, 4),
        "urdu_probability": round(probs[0][0].item(), 4),
        "punjabi_probability": round(probs[0][1].item(), 4)
    }}

demo = gr.Interface(
    fn=detect_language,
    inputs=gr.Textbox(
        label="Enter Urdu or Punjabi text",
        placeholder="Type here... / یہاں لکھیں... / ਇੱਥੇ ਲਿਖੋ...",
        lines=3
    ),
    outputs=gr.JSON(label="Detection Result"),
    title="🌍 Urdu/Punjabi Language Detector",
    description="AI-powered language detection for Urdu (اردو) and Punjabi (پنجابی)",
    examples=[
        ["السلام علیکم، آپ کیسے ہیں؟"],
        ["ਸਤ ਸ੍ਰੀ ਅਕਾਲ، ਤੁਸੀਂ ਕਿਵੇਂ ਹੋ?"],
        ["میں آج بہت خوش ہوں"],
        ["ਮੈਂ ਅੱਜ ਬਹੁਤ ਖੁਸ਼ ਹਾਂ"],
    ],
    theme=gr.themes.Soft(),
    analytics_enabled=False
)

if __name__ == "__main__":
    demo.launch()
'''

print(app_py)
print("\n--- requirements.txt ---")
print("transformers\ntorch\nsentencepiece")

print("\n" + "=" * 70)
print("✅ DEPLOYMENT COMPLETE!")
print("=" * 70)
print(f"\n📦 Model URL: https://huggingface.co/{repo_id}")
print(f"📚 Use in your app: model_id = '{repo_id}'")
print("\n🚀 Next: Create a Gradio Space for interactive demo (optional)")
print("=" * 70)
