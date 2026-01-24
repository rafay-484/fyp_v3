# 🚀 Quick Start: Deploy to Hugging Face

Follow these steps to get your model running on Hugging Face in 10 minutes!

## Step 1: Install Hugging Face CLI (2 minutes)

Open PowerShell and run:

```powershell
cd c:\Users\Dell\projects\fyp_v1\ml_model
.\venv\Scripts\pip.exe install huggingface_hub
```

## Step 2: Create Hugging Face Account (3 minutes)

1. Go to: https://huggingface.co/join
2. Sign up with email
3. Verify your email

## Step 3: Get Your Token (1 minute)

1. Go to: https://huggingface.co/settings/tokens
2. Click "New token"
3. Name: `fyp_app`
4. Type: Write
5. Click "Generate"
6. **COPY THE TOKEN** - you'll need it twice!

## Step 4: Login to Hugging Face (1 minute)

```powershell
cd c:\Users\Dell\projects\fyp_v1\ml_model
.\venv\Scripts\huggingface-cli.exe login
```

When prompted, paste your token and press Enter.

## Step 5: Deploy Your Model (3 minutes)

```powershell
.\venv\Scripts\python.exe deploy_to_huggingface.py
```

When prompted, enter your Hugging Face username (example: `john_doe`)

The script will upload your model. Wait for:
```
✓ Model uploaded successfully!
🎉 Your model is live at: https://huggingface.co/YOUR_USERNAME/urdu-punjabi-classifier
```

## Step 6: Update Your Flutter App (2 minutes)

1. Open `lib/services/ai_service.dart`

2. Find these lines at the top:

```dart
static const String _huggingFaceModel = 'YOUR_USERNAME/urdu-punjabi-classifier';
static const String _huggingFaceToken = 'YOUR_HF_TOKEN_HERE';
```

3. Replace with YOUR values:

```dart
static const String _huggingFaceModel = 'john_doe/urdu-punjabi-classifier';  // Your username!
static const String _huggingFaceToken = 'hf_xxxxxxxxxxxxx';  // Your token!
```

4. Save the file

## Step 7: Test It! (1 minute)

```powershell
cd c:\Users\Dell\projects\fyp_v1
flutter run
```

Your app now uses the cloud-based AI model! No local server needed! 🎉

---

## Troubleshooting

### "Model is loading, please wait..."
- First request after deployment takes 20 seconds (model cold start)
- Subsequent requests are instant
- Just wait and try again

### "401 Unauthorized"
- Check your token in `ai_service.dart`
- Make sure you copied it correctly
- Token should start with `hf_`

### "Repository not found"
- Check your username in `ai_service.dart`
- Make sure model uploaded successfully
- Visit: https://huggingface.co/YOUR_USERNAME/urdu-punjabi-classifier

### Need help?
- Check full guide: HUGGINGFACE_DEPLOYMENT_GUIDE.md
- Hugging Face docs: https://huggingface.co/docs

---

## What You Get

✅ **Free hosting** - No costs, forever  
✅ **Global availability** - Works from anywhere  
✅ **Auto-scaling** - Handles many users  
✅ **No server management** - Just works  
✅ **Fast responses** - ~1-2 seconds  
✅ **Mobile-friendly** - Works on real devices  

Enjoy your cloud-powered AI app! 🚀🤖
