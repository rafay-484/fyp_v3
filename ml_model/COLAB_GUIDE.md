# Google Colab Training Guide - XLM-RoBERTa

## Quick Steps (15 minutes total)

### 1. Prepare Files
- Dataset: `C:\Users\Dell\projects\fyp_v1\ml_model\data\comprehensive_dataset.csv`
- Notebook: `C:\Users\Dell\projects\fyp_v1\ml_model\COLAB_TRAINING.ipynb`

### 2. Upload to Colab
1. Go to: https://colab.research.google.com/
2. Sign in with Google account (free)
3. Click **File → Upload notebook**
4. Upload `COLAB_TRAINING.ipynb`
5. Click folder icon (📁) on left sidebar
6. Click upload icon and upload `comprehensive_dataset.csv`

### 3. Run Training
1. Click **Runtime → Run all** (or press Ctrl+F9)
2. If asked about GPU: Click **Runtime → Change runtime type → Hardware accelerator → GPU → Save**
3. Wait 10-15 minutes (you'll see progress bars)

### 4. Download Trained Model
1. After training completes, look in left sidebar (📁)
2. Find folder: `xlm_roberta_urdu_punjabi`
3. Right-click → **Download**
4. Extract the downloaded zip file
5. Copy the folder to: `C:\Users\Dell\projects\fyp_v1\ml_model\trained_model\`

### 5. Verify Download
Your `trained_model` folder should contain:
```
xlm_roberta_urdu_punjabi/
├── config.json
├── pytorch_model.bin
├── tokenizer_config.json
├── tokenizer.json
├── special_tokens_map.json
└── sentencepiece.bpe.model
```

## Expected Results
- **Accuracy**: 95%+ (the model will classify Urdu vs Punjabi)
- **Training time**: 10-15 minutes on Colab GPU
- **Model size**: ~1.1 GB

## Troubleshooting

### "No GPU available"
- Click **Runtime → Change runtime type**
- Set **Hardware accelerator** to **GPU**
- Click **Save**

### "File not found: comprehensive_dataset.csv"
- Make sure you uploaded the CSV file
- Check it appears in the Files tab (📁) on left

### Out of Memory
- Already optimized for Colab's free tier
- If still failing: In cell 6, change `per_device_train_batch_size=16` to `8`

## Next Steps (After Download)
Once you have the trained model, I'll help you:
1. Convert it to TFLite for Flutter
2. Integrate it into your app
3. Build the final APK

---

**Why Colab?**
- FREE GPU (Tesla T4)
- 12-15 GB RAM
- 10-15 minutes training vs 2-3 hours locally
- Perfect for FYP projects
