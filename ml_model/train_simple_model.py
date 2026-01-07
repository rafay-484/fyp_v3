"""
Simple TF-IDF + Logistic Regression Model for Urdu/Punjabi Classification
No large downloads required - trains instantly on local machine
"""

import pandas as pd
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, classification_report
import pickle
import json
from dataset_generator import generate_massive_urdu_dataset, generate_massive_punjabi_dataset

print("=" * 60)
print("Simple Urdu/Punjabi Language Classifier Training")
print("=" * 60)

# Generate dataset
print("\nGenerating comprehensive dataset...")
urdu_data = generate_massive_urdu_dataset()
punjabi_data = generate_massive_punjabi_dataset()

print(f"✓ Urdu entries: {len(urdu_data)}")
print(f"✓ Punjabi entries: {len(punjabi_data)}")

# Combine datasets
all_data = urdu_data + punjabi_data
print(f"✓ Total entries: {len(all_data)}")

# Create DataFrame
df = pd.DataFrame(all_data)
print(f"\n✓ Dataset shape: {df.shape}")
print(f"✓ Columns: {df.columns.tolist()}")

# Prepare data
X = df['text'].values
y = df['label'].values

print(f"\n✓ Features shape: {X.shape}")
print(f"✓ Labels shape: {y.shape}")
print(f"✓ Urdu label (0): {(y == 0).sum()} samples")
print(f"✓ Punjabi label (1): {(y == 1).sum()} samples")

# Split data
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

print(f"\n✓ Train samples: {len(X_train)}")
print(f"✓ Test samples: {len(X_test)}")

# Create TF-IDF vectorizer for Urdu/Punjabi text
print("\n" + "=" * 60)
print("TRAINING MODEL")
print("=" * 60)

print("\nCreating TF-IDF vectorizer...")
vectorizer = TfidfVectorizer(
    analyzer='char',  # Character-level for Urdu/Punjabi script
    ngram_range=(2, 4),  # Character n-grams
    max_features=5000,
    min_df=2
)

print("Fitting vectorizer...")
X_train_vec = vectorizer.fit_transform(X_train)
X_test_vec = vectorizer.transform(X_test)

print(f"✓ Vectorized train shape: {X_train_vec.shape}")
print(f"✓ Vectorized test shape: {X_test_vec.shape}")

# Train Logistic Regression
print("\nTraining Logistic Regression classifier...")
model = LogisticRegression(
    max_iter=1000,
    C=1.0,
    random_state=42,
    solver='lbfgs'
)

model.fit(X_train_vec, y_train)
print("✓ Model trained!")

# Evaluate
print("\n" + "=" * 60)
print("EVALUATION")
print("=" * 60)

y_train_pred = model.predict(X_train_vec)
y_test_pred = model.predict(X_test_vec)

train_acc = accuracy_score(y_train, y_train_pred)
test_acc = accuracy_score(y_test, y_test_pred)

print(f"\n✓ Train Accuracy: {train_acc:.4f} ({train_acc*100:.2f}%)")
print(f"✓ Test Accuracy: {test_acc:.4f} ({test_acc*100:.2f}%)")

print("\nClassification Report (Test Set):")
print(classification_report(y_test, y_test_pred, 
                          target_names=['Urdu', 'Punjabi']))

# Save model
print("\n" + "=" * 60)
print("SAVING MODEL")
print("=" * 60)

import os
os.makedirs('trained_model', exist_ok=True)

# Save vectorizer and model
with open('trained_model/vectorizer.pkl', 'wb') as f:
    pickle.dump(vectorizer, f)
print("✓ Vectorizer saved to trained_model/vectorizer.pkl")

with open('trained_model/model.pkl', 'wb') as f:
    pickle.dump(model, f)
print("✓ Model saved to trained_model/model.pkl")

# Save metadata
metadata = {
    'model_type': 'TF-IDF + Logistic Regression',
    'total_samples': len(all_data),
    'urdu_samples': len(urdu_data),
    'punjabi_samples': len(punjabi_data),
    'train_accuracy': float(train_acc),
    'test_accuracy': float(test_acc),
    'features': int(X_train_vec.shape[1]),
    'ngram_range': (2, 4),
    'max_features': 5000
}

with open('trained_model/metadata.json', 'w', encoding='utf-8') as f:
    json.dump(metadata, f, indent=2, ensure_ascii=False)
print("✓ Metadata saved to trained_model/metadata.json")

# Save sample predictions
print("\n" + "=" * 60)
print("SAMPLE PREDICTIONS")
print("=" * 60)

samples = [
    "السلام علیکم، کیسے ہیں آپ؟",  # Urdu
    "کی حال اے یار؟",  # Punjabi
    "میں اسکول جا رہا ہوں",  # Urdu
    "میں سکول جا رہیا آں",  # Punjabi
    "آج موسم بہت اچھا ہے",  # Urdu
    "اج موسم بوہت سوہنا اے"  # Punjabi
]

print("\nTesting model on sample sentences:")
for text in samples:
    text_vec = vectorizer.transform([text])
    pred = model.predict(text_vec)[0]
    prob = model.predict_proba(text_vec)[0]
    lang = "Urdu" if pred == 0 else "Punjabi"
    confidence = max(prob) * 100
    print(f"  '{text}'")
    print(f"  → {lang} (confidence: {confidence:.1f}%)\n")

print("=" * 60)
print("✓ TRAINING COMPLETE!")
print("=" * 60)
print(f"\nModel files saved in: trained_model/")
print(f"  - vectorizer.pkl ({os.path.getsize('trained_model/vectorizer.pkl') / 1024:.1f} KB)")
print(f"  - model.pkl ({os.path.getsize('trained_model/model.pkl') / 1024:.1f} KB)")
print(f"  - metadata.json")
print(f"\nTest Accuracy: {test_acc*100:.2f}%")
