# -*- coding: utf-8 -*-
"""
Simple XLM-RoBERTa Training - Manual training loop for better control
"""
import os
import sys
os.environ['TRANSFORMERS_OFFLINE'] = '1'
os.environ['HF_HUB_OFFLINE'] = '1'

# Set UTF-8 encoding for Windows console
if sys.platform == 'win32':
    import codecs
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')
    sys.stderr = codecs.getwriter('utf-8')(sys.stderr.buffer, 'strict')

print("=" * 60)
print("XLM-RoBERTa Training - Urdu/Punjabi")
print("=" * 60)

import torch
from transformers import XLMRobertaTokenizer, XLMRobertaForSequenceClassification
import pandas as pd
from torch.utils.data import DataLoader, Dataset as TorchDataset
from sklearn.metrics import accuracy_score
import json

class TextDataset(TorchDataset):
    def __init__(self, texts, labels, tokenizer, max_length=128):
        self.encodings = tokenizer(texts, truncation=True, padding='max_length', max_length=max_length)
        self.labels = labels
    
    def __getitem__(self, idx):
        item = {key: torch.tensor(val[idx]) for key, val in self.encodings.items()}
        item['labels'] = torch.tensor(self.labels[idx])
        return item
    
    def __len__(self):
        return len(self.labels)

# Load cached model
cache_path = os.path.expanduser("~/.cache/huggingface/hub/models--FacebookAI--xlm-roberta-base/snapshots/e73636d4f797dec63c3081bb6ed5c7b0bb3f2089")

print("\nLoading model...")
tokenizer = XLMRobertaTokenizer.from_pretrained(cache_path, local_files_only=True)
model = XLMRobertaForSequenceClassification.from_pretrained(cache_path, num_labels=2, local_files_only=True)

device = torch.device('cpu')
model.to(device)
print(f"Model loaded on {device}")

# Load dataset
print("\nLoading dataset...")
df = pd.read_csv('data/comprehensive_dataset.csv')
print(f"Total samples: {len(df)}")

# Split data
from sklearn.model_selection import train_test_split
train_texts, test_texts, train_labels, test_labels = train_test_split(
    df['text'].tolist(), df['label'].tolist(), test_size=0.2, random_state=42
)

print(f"Train: {len(train_texts)} | Test: {len(test_texts)}")

# Create datasets
train_dataset = TextDataset(train_texts, train_labels, tokenizer)
test_dataset = TextDataset(test_texts, test_labels, tokenizer)

# Create dataloaders with small batch size
train_loader = DataLoader(train_dataset, batch_size=2, shuffle=True)
test_loader = DataLoader(test_dataset, batch_size=2)

# Training setup
optimizer = torch.optim.AdamW(model.parameters(), lr=2e-5)
epochs = 1  # Just 1 epoch for faster completion

print("\n" + "=" * 60)
print("TRAINING START")
print("=" * 60)
print(f"Epochs: {epochs}")
print(f"Batch size: 2")
print(f"Total batches per epoch: {len(train_loader)}")
print("=" * 60)

model.train()
for epoch in range(epochs):
    total_loss = 0
    correct = 0
    total = 0
    
    for batch_idx, batch in enumerate(train_loader):
        # Move batch to device
        input_ids = batch['input_ids'].to(device)
        attention_mask = batch['attention_mask'].to(device)
        labels = batch['labels'].to(device)
        
        # Forward pass
        optimizer.zero_grad()
        outputs = model(input_ids=input_ids, attention_mask=attention_mask, labels=labels)
        loss = outputs.loss
        
        # Backward pass
        loss.backward()
        optimizer.step()
        
        # Track metrics
        total_loss += loss.item()
        predictions = outputs.logits.argmax(dim=-1)
        correct += (predictions == labels).sum().item()
        total += labels.size(0)
        
        # Print progress every 500 batches
        if (batch_idx + 1) % 500 == 0:
            avg_loss = total_loss / (batch_idx + 1)
            acc = correct / total
            print(f"Epoch {epoch+1} | Batch {batch_idx+1}/{len(train_loader)} | Loss: {avg_loss:.4f} | Acc: {acc*100:.2f}%")
    
    # Epoch summary
    avg_loss = total_loss / len(train_loader)
    train_acc = correct / total
    print(f"\nEpoch {epoch+1} Complete:")
    print(f"  Train Loss: {avg_loss:.4f}")
    print(f"  Train Accuracy: {train_acc*100:.2f}%")

# Evaluation
print("\n" + "=" * 60)
print("EVALUATION")
print("=" * 60)

model.eval()
all_preds = []
all_labels = []

with torch.no_grad():
    for batch in test_loader:
        input_ids = batch['input_ids'].to(device)
        attention_mask = batch['attention_mask'].to(device)
        labels = batch['labels'].to(device)
        
        outputs = model(input_ids=input_ids, attention_mask=attention_mask)
        predictions = outputs.logits.argmax(dim=-1)
        
        all_preds.extend(predictions.cpu().numpy())
        all_labels.extend(labels.cpu().numpy())

test_acc = accuracy_score(all_labels, all_preds)
print(f"Test Accuracy: {test_acc*100:.2f}%")

# Save model
print("\nSaving model...")
output_dir = 'trained_model/xlm_roberta_urdu_punjabi'
os.makedirs(output_dir, exist_ok=True)
model.save_pretrained(output_dir)
tokenizer.save_pretrained(output_dir)

# Save metadata
metadata = {
    'model': 'XLM-RoBERTa-base',
    'task': 'Urdu/Punjabi Classification', 
    'total_samples': len(df),
    'train_samples': len(train_texts),
    'test_samples': len(test_texts),
    'train_accuracy': float(train_acc),
    'test_accuracy': float(test_acc),
    'epochs': epochs
}

with open(os.path.join(output_dir, 'metadata.json'), 'w') as f:
    json.dump(metadata, f, indent=2)

print("\n" + "=" * 60)
print("TRAINING COMPLETE!")
print("=" * 60)
print(f"Model saved to: {output_dir}")
print(f"Test Accuracy: {test_acc*100:.2f}%")
