# 🤗 Hugging Face Deployment Guide

Deploy your XLM-RoBERTa model to Hugging Face and use it in your Flutter app!

## Option 1: Hugging Face Spaces (Recommended - FREE)

### Step 1: Create Hugging Face Account
1. Go to https://huggingface.co/join
2. Sign up (free account)
3. Verify your email

### Step 2: Get Your Access Token
1. Go to https://huggingface.co/settings/tokens
2. Click "New token"
3. Name: `fyp_language_app`
4. Type: Select "Write"
5. Click "Generate"
6. **COPY THIS TOKEN** - you'll need it!

### Step 3: Upload Your Model to Hugging Face

Run these commands in PowerShell:

```powershell
# Install Hugging Face CLI
cd c:\Users\Dell\projects\fyp_v1\ml_model
.\venv\Scripts\pip.exe install huggingface_hub

# Login to Hugging Face
.\venv\Scripts\huggingface-cli.exe login
# Paste your token when prompted

# Upload the model
.\venv\Scripts\python.exe -c "from huggingface_hub import HfApi; api = HfApi(); api.upload_folder(folder_path='trained_model/xlm_roberta_urdu_punjabi', repo_id='YOUR_USERNAME/urdu-punjabi-classifier', repo_type='model')"
```

**Replace `YOUR_USERNAME` with your Hugging Face username!**

### Step 4: Create a Hugging Face Space for API

1. Go to https://huggingface.co/spaces
2. Click "Create new Space"
3. Name: `urdu-punjabi-api`
4. License: MIT
5. Space SDK: **Gradio**
6. Click "Create Space"

### Step 5: Add These Files to Your Space

Create `app.py` in your Space:

```python
import gradio as gr
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch

# Load your model
model_name = "YOUR_USERNAME/urdu-punjabi-classifier"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForSequenceClassification.from_pretrained(model_name)
model.eval()

def detect_language(text):
    inputs = tokenizer(text, return_tensors="pt", truncation=True, max_length=128)
    with torch.no_grad():
        outputs = model(**inputs)
        probs = torch.softmax(outputs.logits, dim=1)
        predicted_class = torch.argmax(probs, dim=1).item()
        confidence = probs[0][predicted_class].item()
    
    language = "urdu" if predicted_class == 0 else "punjabi"
    return {
        "language": language,
        "confidence": confidence,
        "urdu_probability": probs[0][0].item(),
        "punjabi_probability": probs[0][1].item()
    }

# Gradio interface
demo = gr.Interface(
    fn=detect_language,
    inputs=gr.Textbox(label="Enter Urdu or Punjabi text"),
    outputs=gr.JSON(label="Detection Result"),
    title="Urdu/Punjabi Language Detector",
    description="AI-powered language detection for Urdu and Punjabi",
    examples=[
        ["السلام علیکم"],
        ["ਸਤ ਸ੍ਰੀ ਅਕਾਲ"],
    ]
)

if __name__ == "__main__":
    demo.launch()
```

Create `requirements.txt` in your Space:

```
transformers
torch
gradio
```

### Step 6: Your API is Ready! 🎉

Your Space will have a URL like:
```
https://YOUR_USERNAME-urdu-punjabi-api.hf.space
```

API endpoint:
```
https://YOUR_USERNAME-urdu-punjabi-api.hf.space/api/predict
```

---

## Option 2: Use Hugging Face Inference API (Simpler!)

Just upload your model (Step 3 above), then use the Inference API directly!

### API Endpoint:
```
https://api-inference.huggingface.co/models/YOUR_USERNAME/urdu-punjabi-classifier
```

### Headers:
```
Authorization: Bearer YOUR_HF_TOKEN
```

### Request Body:
```json
{
  "inputs": "السلام علیکم"
}
```

---

## Testing Your Deployed Model

### Test with curl:
```bash
curl https://YOUR_USERNAME-urdu-punjabi-api.hf.space/api/predict \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"data": ["السلام علیکم"]}'
```

### Test with PowerShell:
```powershell
$body = @{
    data = @("السلام علیکم")
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://YOUR_USERNAME-urdu-punjabi-api.hf.space/api/predict" -Method Post -Body $body -ContentType "application/json"
```

---

## Next Steps

After deployment, I'll update your Flutter app to use this API instead of localhost!

Your app will work on any device with internet - no local server needed! 🚀
