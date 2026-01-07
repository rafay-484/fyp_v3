"""
XLM-RoBERTa Training with Memory Optimization
Uses gradient accumulation and mixed precision
"""
import os
os.environ['TRANSFORMERS_OFFLINE'] = '1'
os.environ['HF_HUB_OFFLINE'] = '1'

import torch
from transformers import XLMRobertaTokenizer, XLMRobertaForSequenceClassification
import pandas as pd
from torch.utils.data import DataLoader, Dataset as TorchDataset
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
import json
from tqdm import tqdm

class TextDataset(TorchDataset):
    def __init__(self, texts, labels, tokenizer, max_length=128):
        self.encodings = tokenizer(texts, truncation=True, padding='max_length', max_length=max_length, return_tensors='pt')
        self.labels = labels
    
    def __getitem__(self, idx):
        item = {key: val[idx] for key, val in self.encodings.items()}
        item['labels'] = torch.tensor(self.labels[idx])
        return item
    
    def __len__(self):
        return len(self.labels)

print("=" * 60)
print("XLM-RoBERTa Training - Memory Optimized")
print("=" * 60)

# Load cached model
cache_path = r"C:\Users\Dell\.cache\huggingface\hub\models--FacebookAI--xlm-roberta-base\snapshots\e73636d4f797dec63c3081bb6ed5c7b0bb3f2089"

print("\n[1/6] Loading tokenizer...")
tokenizer = XLMRobertaTokenizer.from_pretrained(cache_path, local_files_only=True)
print("Done")

print("[2/6] Loading model...")
model = XLMRobertaForSequenceClassification.from_pretrained(
    cache_path, 
    num_labels=2, 
    local_files_only=True
)
device = torch.device('cpu')
model.to(device)
print(f"Done - using {device}")

print("[3/6] Loading dataset...")
df = pd.read_csv('data/comprehensive_dataset.csv')
print(f"Total: {len(df)} samples")

train_texts, test_texts, train_labels, test_labels = train_test_split(
    df['text'].tolist(), df['label'].tolist(), test_size=0.2, random_state=42
)
print(f"Train: {len(train_texts)} | Test: {len(test_texts)}")

print("[4/6] Creating dataloaders...")
train_dataset = TextDataset(train_texts, train_labels, tokenizer)
test_dataset = TextDataset(test_texts, test_labels, tokenizer)

# Very small batch size
BATCH_SIZE = 1
ACCUMULATION_STEPS = 8  # Effective batch size = 1 * 8 = 8

train_loader = DataLoader(train_dataset, batch_size=BATCH_SIZE, shuffle=True)
test_loader = DataLoader(test_dataset, batch_size=BATCH_SIZE)
print(f"Batch size: {BATCH_SIZE}, Accumulation: {ACCUMULATION_STEPS}")

print("[5/6] Setting up training...")
optimizer = torch.optim.AdamW(model.parameters(), lr=2e-5)
EPOCHS = 1

print("\n" + "=" * 60)
print("TRAINING")
print("=" * 60)
print(f"Total batches: {len(train_loader)}")
print(f"This will take approximately 20-30 minutes")
print("=" * 60 + "\n")

model.train()
for epoch in range(EPOCHS):
    total_loss = 0
    optimizer.zero_grad()
    
    progress_bar = tqdm(train_loader, desc=f"Epoch {epoch+1}/{EPOCHS}")
    
    for batch_idx, batch in enumerate(progress_bar):
        input_ids = batch['input_ids'].to(device)
        attention_mask = batch['attention_mask'].to(device)
        labels = batch['labels'].to(device)
        
        outputs = model(input_ids=input_ids, attention_mask=attention_mask, labels=labels)
        loss = outputs.loss / ACCUMULATION_STEPS
        
        loss.backward()
        total_loss += loss.item() * ACCUMULATION_STEPS
        
        # Update weights every ACCUMULATION_STEPS
        if (batch_idx + 1) % ACCUMULATION_STEPS == 0:
            optimizer.step()
            optimizer.zero_grad()
        
        # Update progress bar
        if (batch_idx + 1) % 100 == 0:
            avg_loss = total_loss / (batch_idx + 1)
            progress_bar.set_postfix({'loss': f'{avg_loss:.4f}'})
    
    # Final update
    optimizer.step()
    optimizer.zero_grad()
    
    avg_loss = total_loss / len(train_loader)
    print(f"\nEpoch {epoch+1} complete - Avg Loss: {avg_loss:.4f}")

print("\n[6/6] Evaluating...")
model.eval()
all_preds = []
all_labels = []

with torch.no_grad():
    for batch in tqdm(test_loader, desc="Testing"):
        input_ids = batch['input_ids'].to(device)
        attention_mask = batch['attention_mask'].to(device)
        labels = batch['labels'].to(device)
        
        outputs = model(input_ids=input_ids, attention_mask=attention_mask)
        predictions = outputs.logits.argmax(dim=-1)
        
        all_preds.extend(predictions.cpu().numpy())
        all_labels.extend(labels.cpu().numpy())

test_acc = accuracy_score(all_labels, all_preds)

print("\n" + "=" * 60)
print("RESULTS")
print("=" * 60)
print(f"Test Accuracy: {test_acc*100:.2f}%")
print("=" * 60)

# Save model
print("\nSaving model...")
output_dir = 'trained_model/xlm_roberta_urdu_punjabi'
os.makedirs(output_dir, exist_ok=True)
model.save_pretrained(output_dir)
tokenizer.save_pretrained(output_dir)

metadata = {
    'model': 'XLM-RoBERTa-base',
    'task': 'Urdu/Punjabi Classification',
    'dataset_size': len(df),
    'train_samples': len(train_texts),
    'test_samples': len(test_texts),
    'test_accuracy': float(test_acc),
    'epochs': EPOCHS,
    'batch_size': BATCH_SIZE,
    'accumulation_steps': ACCUMULATION_STEPS
}

with open(os.path.join(output_dir, 'metadata.json'), 'w') as f:
    json.dump(metadata, f, indent=2)

print(f"\nModel saved to: {output_dir}")
print("\n" + "=" * 60)
print("TRAINING COMPLETE!")
print("=" * 60)
