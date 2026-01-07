"""
Optimized XLM-RoBERTa Training - Direct approach with minimal imports
"""
import os
os.environ['TRANSFORMERS_OFFLINE'] = '1'  # Use offline mode
os.environ['HF_HUB_OFFLINE'] = '1'

print("Starting training...")
print("Loading PyTorch...")
import torch

print("Loading transformers...")
from transformers import XLMRobertaTokenizer, XLMRobertaForSequenceClassification, Trainer, TrainingArguments
from datasets import Dataset
import pandas as pd

print("=" * 60)
print("XLM-RoBERTa Training - Urdu/Punjabi Classification")
print("=" * 60)

# Use cached model
cache_path = os.path.expanduser("~/.cache/huggingface/hub/models--FacebookAI--xlm-roberta-base/snapshots/e73636d4f797dec63c3081bb6ed5c7b0bb3f2089")

print(f"\nChecking for cached model...")
if not os.path.exists(cache_path):
    print(f"❌ Cached model not found at: {cache_path}")
    print("Please run download_model.py first")
    exit(1)

print(f"✓ Found cached model")

# Load dataset
print("\nLoading dataset from data/comprehensive_dataset.csv...")
df = pd.read_csv('data/comprehensive_dataset.csv')
print(f"✓ Loaded {len(df)} entries")
print(f"  - Urdu (label 0): {(df['label'] == 0).sum()}")
print(f"  - Punjabi (label 1): {(df['label'] == 1).sum()}")

# Load tokenizer and model
print("\nLoading tokenizer from cache...")
tokenizer = XLMRobertaTokenizer.from_pretrained(cache_path, local_files_only=True)
print("✓ Tokenizer loaded")

print("\nLoading XLM-RoBERTa model from cache...")
model = XLMRobertaForSequenceClassification.from_pretrained(
    cache_path,
    num_labels=2,
    local_files_only=True
)
print("✓ Model loaded")

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"✓ Using device: {device}")
model.to(device)

# Prepare dataset
print("\nTokenizing dataset...")
def tokenize_function(examples):
    return tokenizer(examples['text'], padding='max_length', truncation=True, max_length=128)

dataset = Dataset.from_pandas(df[['text', 'label']])
tokenized_dataset = dataset.map(tokenize_function, batched=True)
print("✓ Tokenization complete")

# Split dataset
print("\nSplitting dataset (80/20)...")
split_dataset = tokenized_dataset.train_test_split(test_size=0.2, seed=42)
train_dataset = split_dataset['train']
eval_dataset = split_dataset['test']
print(f"✓ Train: {len(train_dataset)} | Test: {len(eval_dataset)}")

# Training arguments
print("\nConfiguring training...")
training_args = TrainingArguments(
    output_dir='./results',
    num_train_epochs=2,  # Reduced to 2 epochs
    per_device_train_batch_size=4,  # Smaller batch size for less memory
    per_device_eval_batch_size=4,
    warmup_steps=50,
    weight_decay=0.01,
    logging_dir='./logs',
    logging_steps=100,
    eval_strategy='epoch',
    save_strategy='epoch',
    load_best_model_at_end=True,
    metric_for_best_model='accuracy',
    dataloader_num_workers=0,  # No multiprocessing
    no_cuda=True,  # Force CPU
)

# Define metrics
def compute_metrics(eval_pred):
    predictions, labels = eval_pred
    predictions = predictions.argmax(axis=-1)
    accuracy = (predictions == labels).mean()
    return {'accuracy': accuracy}

# Initialize trainer
print("\nInitializing Trainer...")
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=train_dataset,
    eval_dataset=eval_dataset,
    compute_metrics=compute_metrics,
)
print("✓ Trainer ready")

# Train
print("\n" + "=" * 60)
print("STARTING TRAINING (3 epochs)")
print("=" * 60)
print("This will take approximately 15-25 minutes...")
print("Do not interrupt!\n")

trainer.train()

print("\n" + "=" * 60)
print("TRAINING COMPLETE!")
print("=" * 60)

# Evaluate
print("\nEvaluating model...")
results = trainer.evaluate()
print(f"\n✓ Test Accuracy: {results['eval_accuracy']*100:.2f}%")

# Save model
print("\nSaving model...")
output_dir = 'trained_model/xlm_roberta_urdu_punjabi'
os.makedirs(output_dir, exist_ok=True)
model.save_pretrained(output_dir)
tokenizer.save_pretrained(output_dir)
print(f"✓ Model saved to: {output_dir}")

# Save metadata
import json
metadata = {
    'model': 'XLM-RoBERTa-base',
    'task': 'Urdu/Punjabi Classification',
    'total_samples': len(df),
    'train_samples': len(train_dataset),
    'test_samples': len(eval_dataset),
    'test_accuracy': float(results['eval_accuracy']),
    'epochs': 3,
    'languages': ['Urdu', 'Punjabi (Shahmukhi)']
}

with open(os.path.join(output_dir, 'metadata.json'), 'w', encoding='utf-8') as f:
    json.dump(metadata, f, indent=2, ensure_ascii=False)

print("\n" + "=" * 60)
print("✓ ALL DONE!")
print("=" * 60)
print(f"Model ready at: {output_dir}")
print(f"Test Accuracy: {results['eval_accuracy']*100:.2f}%")
