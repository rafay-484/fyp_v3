"""
Google Colab Training Script for XLM-RoBERTa
Upload this to Colab and run it there - much faster with GPU
"""

# Install dependencies
!pip install transformers datasets accelerate -q

# Upload your comprehensive_dataset.csv to Colab first, then run:

import torch
from transformers import XLMRobertaTokenizer, XLMRobertaForSequenceClassification, Trainer, TrainingArguments
from datasets import Dataset
import pandas as pd
from sklearn.metrics import accuracy_score
import numpy as np

print("=" * 60)
print("XLM-RoBERTa Training - Urdu/Punjabi")
print("=" * 60)

# Load dataset
df = pd.read_csv('comprehensive_dataset.csv')
print(f"Total samples: {len(df)}")

# Load model
model_name = "FacebookAI/xlm-roberta-base"
tokenizer = XLMRobertaTokenizer.from_pretrained(model_name)
model = XLMRobertaForSequenceClassification.from_pretrained(model_name, num_labels=2)

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"Using device: {device}")
model.to(device)

# Tokenize
def tokenize_function(examples):
    return tokenizer(examples['text'], padding='max_length', truncation=True, max_length=128)

dataset = Dataset.from_pandas(df[['text', 'label']])
tokenized_dataset = dataset.map(tokenize_function, batched=True)

# Split
split_dataset = tokenized_dataset.train_test_split(test_size=0.2, seed=42)
train_dataset = split_dataset['train']
eval_dataset = split_dataset['test']

# Training args
training_args = TrainingArguments(
    output_dir='./results',
    num_train_epochs=3,
    per_device_train_batch_size=16,
    per_device_eval_batch_size=16,
    warmup_steps=100,
    weight_decay=0.01,
    logging_steps=50,
    eval_strategy='epoch',
    save_strategy='epoch',
    load_best_model_at_end=True,
)

def compute_metrics(eval_pred):
    predictions, labels = eval_pred
    predictions = predictions.argmax(axis=-1)
    accuracy = (predictions == labels).mean()
    return {'accuracy': accuracy}

# Train
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=train_dataset,
    eval_dataset=eval_dataset,
    compute_metrics=compute_metrics,
)

print("Training...")
trainer.train()

# Evaluate
results = trainer.evaluate()
print(f"Test Accuracy: {results['eval_accuracy']*100:.2f}%")

# Save
model.save_pretrained('./xlm_roberta_urdu_punjabi')
tokenizer.save_pretrained('./xlm_roberta_urdu_punjabi')

# Download the model from Colab
print("\nModel trained! Download the 'xlm_roberta_urdu_punjabi' folder")
