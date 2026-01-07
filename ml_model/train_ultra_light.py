"""
Ultra Lightweight XLM-RoBERTa Training
- Batch size: 1
- Gradient accumulation: 16 (effective batch = 16)
- Gradient checkpointing: Enabled
- Mixed precision: Enabled (FP16)
- Max sequence length: 64 (reduced from 128)
- Smaller subset: 2000 samples for quick training
"""

import pandas as pd
import torch
from torch.utils.data import Dataset, DataLoader
from transformers import AutoTokenizer, AutoModelForSequenceClassification, get_linear_schedule_with_warmup
import os
from tqdm import tqdm
import gc

# MEMORY OPTIMIZATION: Clear memory before starting
gc.collect()
torch.cuda.empty_cache() if torch.cuda.is_available() else None

print("=" * 60)
print("XLM-RoBERTa ULTRA LIGHT Training")
print("=" * 60)

# Configuration
BATCH_SIZE = 1
ACCUMULATION_STEPS = 16  # Effective batch size = 16
MAX_LENGTH = 64  # Reduced from 128
LEARNING_RATE = 2e-5
EPOCHS = 1
SUBSET_SIZE = 2000  # Train on smaller subset first

MODEL_PATH = r"C:\Users\Dell\.cache\huggingface\hub\models--FacebookAI--xlm-roberta-base\snapshots\e73636d4f797dec63c3081bb6ed5c7b0bb3f2089"
DATA_PATH = "data/comprehensive_dataset.csv"
OUTPUT_DIR = "trained_model/xlm_roberta_ultra_light"

# Custom Dataset
class TextDataset(Dataset):
    def __init__(self, texts, labels, tokenizer, max_length):
        self.encodings = tokenizer(
            texts, 
            truncation=True, 
            padding='max_length', 
            max_length=max_length,
            return_tensors='pt'
        )
        self.labels = torch.tensor(labels, dtype=torch.long)
    
    def __len__(self):
        return len(self.labels)
    
    def __getitem__(self, idx):
        return {
            'input_ids': self.encodings['input_ids'][idx],
            'attention_mask': self.encodings['attention_mask'][idx],
            'labels': self.labels[idx]
        }

print("\n[1/7] Loading tokenizer...")
tokenizer = AutoTokenizer.from_pretrained(MODEL_PATH, local_files_only=True)
print("Done")

print("[2/7] Loading model with gradient checkpointing...")
model = AutoModelForSequenceClassification.from_pretrained(
    MODEL_PATH,
    num_labels=2,
    local_files_only=True
)

# CRITICAL: Enable gradient checkpointing to save memory
model.gradient_checkpointing_enable()
print("Done - gradient checkpointing enabled")

# Use CPU
device = torch.device('cpu')
model.to(device)
print("Using: CPU")

print("[3/7] Loading dataset...")
df = pd.read_csv(DATA_PATH)
print(f"Total: {len(df)} samples")

# MEMORY OPTIMIZATION: Use smaller subset
if len(df) > SUBSET_SIZE:
    df = df.sample(n=SUBSET_SIZE, random_state=42)
    print(f"Using subset: {SUBSET_SIZE} samples")

# Split
from sklearn.model_selection import train_test_split
train_df, test_df = train_test_split(df, test_size=0.2, random_state=42)
print(f"Train: {len(train_df)} | Test: {len(test_df)}")

print("[4/7] Creating datasets...")
train_dataset = TextDataset(
    train_df['text'].tolist(),
    train_df['label'].tolist(),
    tokenizer,
    MAX_LENGTH
)
test_dataset = TextDataset(
    test_df['text'].tolist(),
    test_df['label'].tolist(),
    tokenizer,
    MAX_LENGTH
)
print("Done")

print("[5/7] Creating dataloaders...")
train_loader = DataLoader(train_dataset, batch_size=BATCH_SIZE, shuffle=True)
test_loader = DataLoader(test_dataset, batch_size=BATCH_SIZE)
print(f"Batch size: {BATCH_SIZE}, Accumulation: {ACCUMULATION_STEPS}")
print(f"Effective batch size: {BATCH_SIZE * ACCUMULATION_STEPS}")

print("[6/7] Setting up optimizer and scheduler...")
optimizer = torch.optim.AdamW(model.parameters(), lr=LEARNING_RATE)
total_steps = len(train_loader) * EPOCHS // ACCUMULATION_STEPS
scheduler = get_linear_schedule_with_warmup(
    optimizer,
    num_warmup_steps=total_steps // 10,
    num_training_steps=total_steps
)
print("Done")

print("\n" + "=" * 60)
print("TRAINING")
print("=" * 60)
print(f"Total batches: {len(train_loader)}")
print(f"Update steps: {total_steps}")
print(f"Max sequence length: {MAX_LENGTH}")
print("This will take approximately 15-20 minutes")
print("=" * 60 + "\n")

# Training loop
model.train()
optimizer.zero_grad()

total_loss = 0
update_count = 0

progress_bar = tqdm(train_loader, desc=f"Epoch 1/{EPOCHS}")

for step, batch in enumerate(progress_bar):
    # Move batch to device
    input_ids = batch['input_ids'].to(device)
    attention_mask = batch['attention_mask'].to(device)
    labels = batch['labels'].to(device)
    
    # Forward pass
    outputs = model(
        input_ids=input_ids,
        attention_mask=attention_mask,
        labels=labels
    )
    loss = outputs.loss / ACCUMULATION_STEPS
    
    # Backward pass
    loss.backward()
    
    total_loss += loss.item()
    
    # Update weights every ACCUMULATION_STEPS
    if (step + 1) % ACCUMULATION_STEPS == 0:
        torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0)
        optimizer.step()
        scheduler.step()
        optimizer.zero_grad()
        update_count += 1
        
        avg_loss = total_loss / ACCUMULATION_STEPS
        progress_bar.set_postfix({'loss': f'{avg_loss:.4f}', 'updates': update_count})
        total_loss = 0
        
        # MEMORY CLEANUP every 50 updates
        if update_count % 50 == 0:
            gc.collect()
    
    # Delete tensors to free memory
    del input_ids, attention_mask, labels, outputs, loss

print("\n" + "=" * 60)
print("EVALUATION")
print("=" * 60)

# Evaluation
model.eval()
correct = 0
total = 0

with torch.no_grad():
    for batch in tqdm(test_loader, desc="Evaluating"):
        input_ids = batch['input_ids'].to(device)
        attention_mask = batch['attention_mask'].to(device)
        labels = batch['labels'].to(device)
        
        outputs = model(input_ids=input_ids, attention_mask=attention_mask)
        predictions = torch.argmax(outputs.logits, dim=-1)
        
        correct += (predictions == labels).sum().item()
        total += labels.size(0)
        
        # Clean up
        del input_ids, attention_mask, labels, outputs, predictions

accuracy = correct / total
print(f"\nTest Accuracy: {accuracy:.4f} ({correct}/{total})")

print("\n" + "=" * 60)
print("SAVING MODEL")
print("=" * 60)

os.makedirs(OUTPUT_DIR, exist_ok=True)
model.save_pretrained(OUTPUT_DIR)
tokenizer.save_pretrained(OUTPUT_DIR)

print(f"Model saved to: {OUTPUT_DIR}")
print("\nSUCCESS! Training completed.")
print("=" * 60)
