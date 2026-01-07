# Complete training in one cell - INCLUDES API SERVER
import os
os.environ['WANDB_DISABLED'] = 'true'

!pip install transformers datasets accelerate flask flask-ngrok pyngrok -q

import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification, Trainer, TrainingArguments
from datasets import Dataset
import pandas as pd
from sklearn.metrics import accuracy_score, precision_recall_fscore_support
from flask import Flask, request, jsonify
from pyngrok import ngrok
import threading

# Load data
df = pd.read_csv('comprehensive_dataset.csv')
print(f'Total: {len(df)} samples')

# Load model
model_name = "FacebookAI/xlm-roberta-base"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForSequenceClassification.from_pretrained(model_name, num_labels=2)

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f'Using: {device}')

# Tokenize
def tokenize_function(examples):
    return tokenizer(examples['text'], padding='max_length', truncation=True, max_length=128)

dataset = Dataset.from_pandas(df[['text', 'label']])
tokenized_dataset = dataset.map(tokenize_function, batched=True)
split_dataset = tokenized_dataset.train_test_split(test_size=0.2, seed=42)

# Training args
training_args = TrainingArguments(
    output_dir='./results',
    num_train_epochs=3,
    per_device_train_batch_size=16,
    learning_rate=2e-5,
    eval_strategy='epoch',
    save_strategy='epoch',
    fp16=torch.cuda.is_available(),
    report_to='none'
)

# Train
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=split_dataset['train'],
    eval_dataset=split_dataset['test']
)

print('Training...')
trainer.train()

# Save
model.save_pretrained('./xlm_roberta_urdu_punjabi')
tokenizer.save_pretrained('./xlm_roberta_urdu_punjabi')

print('✓ Training DONE!')

# ============================================================
# START API SERVER
# ============================================================

print('\n' + '='*60)
print('STARTING API SERVER')
print('='*60)

# Reload model for inference
model = AutoModelForSequenceClassification.from_pretrained('./xlm_roberta_urdu_punjabi')
model.to(device)
model.eval()

app = Flask(__name__)

@app.route('/detect', methods=['POST'])
def detect_language():
    try:
        data = request.get_json()
        text = data['text']
        
        inputs = tokenizer(text, return_tensors='pt', padding=True, truncation=True, max_length=128)
        inputs = {k: v.to(device) for k, v in inputs.items()}
        
        with torch.no_grad():
            outputs = model(**inputs)
            logits = outputs.logits
            probabilities = torch.softmax(logits, dim=-1)[0]
            prediction = torch.argmax(logits, dim=-1).item()
            confidence = probabilities[prediction].item()
        
        language = 'urdu' if prediction == 0 else 'punjabi'
        
        return jsonify({
            'text': text,
            'prediction': prediction,
            'language': language,
            'confidence': confidence
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Setup ngrok tunnel
public_url = ngrok.connect(5000)
print('\n' + '='*60)
print(f'API is live at: {public_url}')
print('='*60)
print('\nUse this URL in your Flutter app:')
print(f'{public_url}/detect')
print('\nPress Ctrl+C to stop')
print('='*60 + '\n')

# Run Flask
app.run(port=5000)
