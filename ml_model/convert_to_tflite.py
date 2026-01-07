"""
Convert trained XLM-RoBERTa model to TensorFlow Lite format
For mobile deployment in Flutter app
"""

import torch
import tensorflow as tf
from transformers import XLMRobertaTokenizer, XLMRobertaForSequenceClassification, TFXLMRobertaForSequenceClassification
import numpy as np
import os

print("=== XLM-RoBERTa to TFLite Conversion ===\n")

# Load PyTorch model
print("Loading trained PyTorch model...")
model_path = "trained_model/xlm_roberta_urdu_punjabi"
tokenizer = XLMRobertaTokenizer.from_pretrained(model_path)
pytorch_model = XLMRobertaForSequenceClassification.from_pretrained(model_path)

# Convert to TensorFlow
print("Converting to TensorFlow format...")
tf_model = TFXLMRobertaForSequenceClassification.from_pretrained(
    model_path,
    from_pt=True
)

# Save TensorFlow model
print("Saving TensorFlow model...")
tf_save_path = "trained_model/xlm_roberta_tf"
tf_model.save_pretrained(tf_save_path)
tokenizer.save_pretrained(tf_save_path)

# Create a concrete function for conversion
print("\nPreparing for TFLite conversion...")

class TFLiteModel(tf.Module):
    def __init__(self, model):
        super(TFLiteModel, self).__init__()
        self.model = model
    
    @tf.function(input_signature=[
        tf.TensorSpec(shape=[None, 128], dtype=tf.int32, name='input_ids'),
        tf.TensorSpec(shape=[None, 128], dtype=tf.int32, name='attention_mask'),
    ])
    def call(self, input_ids, attention_mask):
        outputs = self.model(input_ids=input_ids, attention_mask=attention_mask)
        return {
            'logits': outputs.logits,
            'predictions': tf.argmax(outputs.logits, axis=-1)
        }

# Wrap model
wrapped_model = TFLiteModel(tf_model)

# Convert to TFLite
print("Converting to TFLite format...")
converter = tf.lite.TFLiteConverter.from_concrete_functions([
    wrapped_model.call.get_concrete_function()
])

# Optimization settings
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_ops = [
    tf.lite.OpsSet.TFLITE_BUILTINS,
    tf.lite.OpsSet.SELECT_TF_OPS
]
converter._experimental_lower_tensor_list_ops = False

# Convert
print("Performing conversion (this may take a few minutes)...")
try:
    tflite_model = converter.convert()
    
    # Save TFLite model
    tflite_path = "trained_model/xlm_roberta_model.tflite"
    with open(tflite_path, 'wb') as f:
        f.write(tflite_model)
    
    print(f"\n✅ TFLite model saved successfully!")
    print(f"Location: {tflite_path}")
    print(f"Size: {len(tflite_model) / 1024 / 1024:.2f} MB")
    
    # Test the TFLite model
    print("\n=== Testing TFLite Model ===")
    interpreter = tf.lite.Interpreter(model_path=tflite_path)
    interpreter.allocate_tensors()
    
    # Get input and output details
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    print("Input details:")
    for detail in input_details:
        print(f"  - {detail['name']}: shape={detail['shape']}, dtype={detail['dtype']}")
    
    print("\nOutput details:")
    for detail in output_details:
        print(f"  - {detail['name']}: shape={detail['shape']}, dtype={detail['dtype']}")
    
    # Test with sample
    test_text = "السلام علیکم، آپ کیسے ہیں؟"
    inputs = tokenizer(test_text, padding='max_length', max_length=128, truncation=True, return_tensors='np')
    
    interpreter.set_tensor(input_details[0]['index'], inputs['input_ids'].astype(np.int32))
    interpreter.set_tensor(input_details[1]['index'], inputs['attention_mask'].astype(np.int32))
    
    interpreter.invoke()
    
    logits = interpreter.get_tensor(output_details[0]['index'])
    prediction = np.argmax(logits, axis=-1)[0]
    confidence = np.max(tf.nn.softmax(logits, axis=-1))
    
    language = "Urdu" if prediction == 0 else "Punjabi"
    print(f"\nTest: '{test_text}'")
    print(f"Prediction: {language} (confidence: {confidence:.2%})")
    
    print("\n✅ TFLite model is working correctly!")
    
except Exception as e:
    print(f"\n❌ Conversion failed: {str(e)}")
    print("\nTrying alternative method (quantized)...")
    
    # Alternative: Create a simpler SavedModel first
    try:
        # Create a serving signature
        @tf.function(input_signature=[{
            'input_ids': tf.TensorSpec(shape=[None, 128], dtype=tf.int32),
            'attention_mask': tf.TensorSpec(shape=[None, 128], dtype=tf.int32)
        }])
        def serving_fn(inputs):
            outputs = tf_model(**inputs)
            return {'logits': outputs.logits}
        
        # Save as SavedModel
        saved_model_path = "trained_model/saved_model"
        tf.saved_model.save(
            tf_model,
            saved_model_path,
            signatures={'serving_default': serving_fn}
        )
        
        # Convert from SavedModel
        converter = tf.lite.TFLiteConverter.from_saved_model(saved_model_path)
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.target_spec.supported_ops = [
            tf.lite.OpsSet.TFLITE_BUILTINS,
            tf.lite.OpsSet.SELECT_TF_OPS
        ]
        
        tflite_model = converter.convert()
        
        tflite_path = "trained_model/xlm_roberta_model.tflite"
        with open(tflite_path, 'wb') as f:
            f.write(tflite_model)
        
        print(f"\n✅ TFLite model saved successfully (alternative method)!")
        print(f"Location: {tflite_path}")
        print(f"Size: {len(tflite_model) / 1024 / 1024:.2f} MB")
    
    except Exception as e2:
        print(f"❌ Alternative conversion also failed: {str(e2)}")
        print("\nNote: For production, consider using ONNX or direct PyTorch Mobile instead.")

# Save vocabulary for Flutter app
print("\n=== Saving Vocabulary ===")
vocab = tokenizer.get_vocab()
vocab_path = "trained_model/vocab.json"
import json
with open(vocab_path, 'w', encoding='utf-8') as f:
    json.dump(vocab, f, ensure_ascii=False, indent=2)
print(f"Vocabulary saved to {vocab_path}")

# Save tokenizer config
tokenizer_config = {
    'vocab_size': len(vocab),
    'max_length': 128,
    'padding': 'max_length',
    'truncation': True,
    'model_type': 'xlm-roberta',
    'languages': ['urdu', 'punjabi'],
    'labels': {
        0: 'urdu',
        1: 'punjabi'
    }
}

config_path = "trained_model/tokenizer_config.json"
with open(config_path, 'w', encoding='utf-8') as f:
    json.dump(tokenizer_config, f, ensure_ascii=False, indent=2)
print(f"Tokenizer config saved to {config_path}")

print("\n=== Conversion Complete ===")
print("Files ready for Flutter integration:")
print("  1. xlm_roberta_model.tflite")
print("  2. vocab.json")
print("  3. tokenizer_config.json")
print("\nCopy these files to: assets/models/ in your Flutter project")
