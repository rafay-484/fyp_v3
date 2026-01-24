# 🚀 Deploy to Hugging Face - Complete Guide

**Your HF Token:** `[YOUR_TOKEN_HERE]`

## 📋 Prerequisites Checklist
- ✅ Trained model exists
- ✅ Flutter web support ready
- ✅ Hugging Face token ready

---

## Part 1: Deploy ML Model to Hugging Face (10 mins)

### Step 1: Login to Hugging Face CLI

Open PowerShell and run:

```powershell
cd c:\Users\Dell\projects\fyp_v1\ml_model
.\venv\Scripts\huggingface-cli.exe login
```

When prompted, paste your token: `[YOUR_TOKEN_HERE]`

### Step 2: Get Your Hugging Face Username

1. Go to https://huggingface.co/settings/account
2. Note your username (it's at the top)

### Step 3: Deploy the Model

Run the deployment script:

```powershell
.\venv\Scripts\python.exe deploy_to_huggingface.py
```

When prompted, enter your Hugging Face username.

**Expected Output:**
```
✓ Repository created/exists: https://huggingface.co/YOUR_USERNAME/urdu-punjabi-classifier
✓ Model uploaded successfully!
🎉 Your model is live at: https://huggingface.co/YOUR_USERNAME/urdu-punjabi-classifier
```

**Copy your model URL** - you'll need it!

---

## Part 2: Create Hugging Face Space (API Endpoint) (5 mins)

### Step 4: Create a Space

1. Go to https://huggingface.co/spaces
2. Click **"Create new Space"**
3. Fill in:
   - **Name:** `urdu-punjabi-api`
   - **License:** MIT
   - **Space SDK:** Gradio
   - **Space visibility:** Public (or Private)
4. Click **"Create Space"**

### Step 5: Add Files to Space

In your new Space, click **"Files"** → **"Add file"** → **"Create a new file"**

**File 1: app.py**

```python
import gradio as gr
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch

# Replace YOUR_USERNAME with your actual username!
MODEL_NAME = "YOUR_USERNAME/urdu-punjabi-classifier"

print(f"Loading model: {MODEL_NAME}")
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
model = AutoModelForSequenceClassification.from_pretrained(MODEL_NAME)
model.eval()
print("Model loaded successfully!")

def detect_language(text):
    if not text or not text.strip():
        return {
            "error": "Please enter some text",
            "language": None,
            "confidence": 0
        }
    
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
    
    return {
        "language": language,
        "confidence": round(confidence, 4),
        "urdu_probability": round(probs[0][0].item(), 4),
        "punjabi_probability": round(probs[0][1].item(), 4)
    }

demo = gr.Interface(
    fn=detect_language,
    inputs=gr.Textbox(
        label="Enter Urdu or Punjabi text",
        placeholder="مثال: السلام علیکم یا ਸਤ ਸ੍ਰੀ ਅਕਾਲ",
        lines=3
    ),
    outputs=gr.JSON(label="Detection Result"),
    title="🌍 Urdu/Punjabi Language Detector",
    description="AI-powered language detection for Urdu (اردو) and Punjabi (پنجابی)",
    examples=[
        ["السلام علیکم، آپ کیسے ہیں؟"],
        ["ਸਤ ਸ੍ਰੀ ਅਕਾਲ، ਤੁਸੀਂ ਕਿਵੇਂ ਹੋ?"],
        ["میں آج بہت خوش ہوں"],
        ["ਮੈਂ ਅੱਜ ਬਹੁਤ ਖੁਸ਼ ਹਾਂ"]
    ],
    theme=gr.themes.Soft()
)

if __name__ == "__main__":
    demo.launch()
```

Click **"Commit new file to main"**

**File 2: requirements.txt**

Create another file named `requirements.txt`:

```
transformers==4.36.0
torch==2.1.0
gradio==4.44.0
```

Click **"Commit new file to main"**

### Step 6: Wait for Space to Build

- Your Space will automatically build (takes 2-5 minutes)
- Once ready, you'll see the interface
- Your API endpoint will be: `https://YOUR_USERNAME-urdu-punjabi-api.hf.space`

---

## Part 3: Deploy Flutter App to Hugging Face (15 mins)

### Step 7: Build Flutter Web App

```powershell
cd c:\Users\Dell\projects\fyp_v1
flutter build web --release
```

This creates optimized web files in `build/web/`

### Step 8: Create Flutter App Space

1. Go to https://huggingface.co/spaces
2. Click **"Create new Space"**
3. Fill in:
   - **Name:** `urdu-punjabi-learning-app`
   - **License:** MIT
   - **Space SDK:** Static
   - **Space visibility:** Public
4. Click **"Create Space"**

### Step 9: Upload Flutter Web Files

Option A: **Using Git (Recommended)**

```powershell
cd c:\Users\Dell\projects\fyp_v1\build\web

# Initialize git
git init
git add .
git commit -m "Initial Flutter app deployment"

# Add Hugging Face remote (replace YOUR_USERNAME)
git remote add origin https://huggingface.co/spaces/YOUR_USERNAME/urdu-punjabi-learning-app

# Push
git push --force origin main
```

If prompted for credentials:
- Username: Your HF username
- Password: `[YOUR_TOKEN_HERE]`

Option B: **Using Web Interface**

1. In your Space, click **"Files"** → **"Add file"** → **"Upload files"**
2. Drag and drop ALL files from `c:\Users\Dell\projects\fyp_v1\build\web\`
3. Click **"Commit files"**

---

## Part 4: Update Flutter App to Use HF API (Optional)

If you want your Flutter app to use the HF-hosted model:

### Step 10: Update AI Service

Edit `lib/services/ai_service.dart`:

```dart
class AIService {
  static const String _apiUrl = 'https://YOUR_USERNAME-urdu-punjabi-api.hf.space/api/predict';
  static const String _hfToken = '[YOUR_TOKEN_HERE]';
  
  Future<String> detectLanguage(String text) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_hfToken',
      },
      body: jsonEncode({'data': [text]}),
    );
    
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['data'][0]['language'];
    }
    throw Exception('Failed to detect language');
  }
}
```

Then rebuild and redeploy:

```powershell
flutter build web --release
# Then upload again to HF Space
```

---

## 🎯 Final URLs

After completing all steps, you'll have:

1. **ML Model:** `https://huggingface.co/YOUR_USERNAME/urdu-punjabi-classifier`
2. **API Endpoint:** `https://YOUR_USERNAME-urdu-punjabi-api.hf.space`
3. **Flutter App:** `https://huggingface.co/spaces/YOUR_USERNAME/urdu-punjabi-learning-app`

---

## 🐛 Troubleshooting

### Issue: "huggingface-cli not found"

```powershell
cd c:\Users\Dell\projects\fyp_v1\ml_model
.\venv\Scripts\pip.exe install huggingface_hub[cli]
```

### Issue: "Model upload failed"

Check internet connection and try again. Large models take time!

### Issue: "Space build failed"

- Check `requirements.txt` has all dependencies
- Check `app.py` has correct model name
- View Space logs for errors

### Issue: "Flutter app doesn't load"

- Make sure all files from `build/web` are uploaded
- Check browser console for errors
- Ensure `index.html` is in root of Space

---

## 📧 Need Help?

- Hugging Face Docs: https://huggingface.co/docs
- Flutter Web Docs: https://docs.flutter.dev/platform-integration/web

---

## ✅ Quick Start Command Sequence

```powershell
# 1. Login to HF
cd c:\Users\Dell\projects\fyp_v1\ml_model
.\venv\Scripts\huggingface-cli.exe login
# Paste: [YOUR_TOKEN_HERE]

# 2. Deploy model
.\venv\Scripts\python.exe deploy_to_huggingface.py

# 3. Build Flutter web
cd c:\Users\Dell\projects\fyp_v1
flutter build web --release

# 4. Your files are ready in: build/web/
# Upload to HF Space manually or via git
```

**That's it! Your app is now LIVE on Hugging Face! 🎉**
