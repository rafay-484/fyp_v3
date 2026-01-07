"""
Flask API server for XLM-RoBERTa language detection
Serves the trained Urdu/Punjabi classification model
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import os
import gc

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

# Load model at startup with memory optimization
MODEL_PATH = "trained_model/xlm_roberta_urdu_punjabi"
print(f"Loading model from {MODEL_PATH}...")

# Clear memory before loading
gc.collect()
torch.cuda.empty_cache() if torch.cuda.is_available() else None

# Use CPU only and load with low memory mode
device = torch.device('cpu')
print("Loading tokenizer...")
tokenizer = AutoTokenizer.from_pretrained(MODEL_PATH)

print("Loading model (this may take 1-2 minutes)...")
# Load model with memory mapping to avoid paging file issues
model = AutoModelForSequenceClassification.from_pretrained(
    MODEL_PATH,
    low_cpu_mem_usage=True,
    torch_dtype=torch.float32
)
model.to(device)
model.eval()

# Clear memory after loading
gc.collect()

print(f"Model loaded successfully on {device}")

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'model': 'xlm-roberta-urdu-punjabi',
        'device': str(device)
    })

@app.route('/detect', methods=['POST'])
def detect_language():
    """
    Detect language from text
    
    Request body:
    {
        "text": "سلام، کی حال اے؟"
    }
    
    Response:
    {
        "text": "سلام، کی حال اے؟",
        "prediction": 1,
        "language": "punjabi",
        "confidence": 0.95,
        "probabilities": {
            "urdu": 0.05,
            "punjabi": 0.95
        }
    }
    """
    try:
        data = request.get_json()
        
        if not data or 'text' not in data:
            return jsonify({'error': 'Missing "text" field'}), 400
        
        text = data['text']
        
        if not text or not text.strip():
            return jsonify({'error': 'Text cannot be empty'}), 400
        
        # Tokenize
        inputs = tokenizer(
            text,
            return_tensors='pt',
            padding=True,
            truncation=True,
            max_length=128
        )
        inputs = {k: v.to(device) for k, v in inputs.items()}
        
        # Predict
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
            'confidence': confidence,
            'probabilities': {
                'urdu': probabilities[0].item(),
                'punjabi': probabilities[1].item()
            }
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/detect/batch', methods=['POST'])
def detect_language_batch():
    """
    Detect language for multiple texts
    
    Request body:
    {
        "texts": ["سلام", "کی حال اے؟", "یہ کتاب ہے"]
    }
    
    Response:
    {
        "results": [
            {"text": "سلام", "prediction": 0, "language": "urdu", "confidence": 0.92},
            ...
        ]
    }
    """
    try:
        data = request.get_json()
        
        if not data or 'texts' not in data:
            return jsonify({'error': 'Missing "texts" field'}), 400
        
        texts = data['texts']
        
        if not isinstance(texts, list) or not texts:
            return jsonify({'error': 'texts must be a non-empty list'}), 400
        
        results = []
        
        for text in texts:
            if not text or not text.strip():
                results.append({
                    'text': text,
                    'error': 'Empty text'
                })
                continue
            
            # Tokenize
            inputs = tokenizer(
                text,
                return_tensors='pt',
                padding=True,
                truncation=True,
                max_length=128
            )
            inputs = {k: v.to(device) for k, v in inputs.items()}
            
            # Predict
            with torch.no_grad():
                outputs = model(**inputs)
                logits = outputs.logits
                probabilities = torch.softmax(logits, dim=-1)[0]
                prediction = torch.argmax(logits, dim=-1).item()
                confidence = probabilities[prediction].item()
            
            language = 'urdu' if prediction == 0 else 'punjabi'
            
            results.append({
                'text': text,
                'prediction': prediction,
                'language': language,
                'confidence': confidence,
                'probabilities': {
                    'urdu': probabilities[0].item(),
                    'punjabi': probabilities[1].item()
                }
            })
        
        return jsonify({'results': results})
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/generate_vocabulary', methods=['POST'])
def generate_vocabulary():
    """
    Generate vocabulary for a specific chapter and lesson using the trained model
    
    Request body:
    {
        "chapter_id": "urdu_ch1",
        "lesson_index": 0,
        "language": "urdu",
        "count": 10
    }
    
    Response:
    {
        "vocabulary": [
            {
                "word": "سلام",
                "translation": "Hello/Peace",
                "pronunciation": "salaam",
                "example": "سلام، کیا حال ہے؟",
                "confidence": 0.95
            },
            ...
        ]
    }
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'Missing request body'}), 400
        
        chapter_id = data.get('chapter_id', 'urdu_ch1')
        lesson_index = data.get('lesson_index', 0)
        language = data.get('language', 'urdu')
        count = data.get('count', 10)
        
        # Load vocabulary from the trained dataset based on chapter topic
        vocabulary_db = load_vocabulary_from_dataset(language, chapter_id, lesson_index, count)
        
        return jsonify({
            'vocabulary': vocabulary_db,
            'chapter_id': chapter_id,
            'lesson_index': lesson_index,
            'language': language,
            'model': 'xlm-roberta-urdu-punjabi',
            'total': len(vocabulary_db)
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

def load_vocabulary_from_dataset(language, chapter_id, lesson_index, count):
    """
    Load vocabulary from the comprehensive dataset based on trained model
    This uses the actual training data the XLM-RoBERTa model was trained on
    """
    import pandas as pd
    import random
    
    # Map chapter IDs to categories from our 8197-entry dataset
    chapter_topics = {
        'urdu_ch1': 'greeting',
        'urdu_ch2': 'shopping',
        'urdu_ch3': 'travel',
        'urdu_ch4': 'restaurant',
        'urdu_ch5': 'office',
        'urdu_ch6': 'technology',
        'urdu_ch7': 'formal',
        'urdu_ch8': 'poetic',
        'urdu_ch9': 'medical',
        'urdu_ch10': 'education',
        'punjabi_ch1': 'lahore_greeting',
        'punjabi_ch2': 'lahore_daily',
        'punjabi_ch3': 'faisalabad_greeting',
        'punjabi_ch4': 'multan_greeting',
        'punjabi_ch5': 'lahore_shopping',
        'punjabi_ch6': 'punjabi_food',
        'punjabi_ch7': 'punjabi_family',
        'punjabi_ch8': 'punjabi_poetic',
        'punjabi_ch9': 'punjabi_rural',
        'punjabi_ch10': 'punjabi_urban'
    }
    
    try:
        # Load the comprehensive dataset
        df = pd.read_csv('ml_model/data/comprehensive_dataset.csv')
        
        # Filter by language
        df_lang = df[df['language'] == language]
        
        # Get topic for this chapter
        topic = chapter_topics.get(chapter_id, 'greeting')
        
        # Filter by category (or partial match)
        df_filtered = df_lang[df_lang['category'].str.contains(topic.split('_')[0], na=False, case=False)]
        
        # If not enough items, use all language data
        if len(df_filtered) < count:
            df_filtered = df_lang
        
        # Sample random vocabulary for this lesson (different each time based on lesson_index seed)
        random.seed(lesson_index * 1000 + hash(chapter_id))
        sampled = df_filtered.sample(n=min(count, len(df_filtered)), replace=False)
        
        vocabulary = []
        for _, row in sampled.iterrows():
            # Use model to verify and get confidence
            text = row['text']
            inputs = tokenizer(
                text,
                return_tensors='pt',
                padding=True,
                truncation=True,
                max_length=128
            )
            inputs = {k: v.to(device) for k, v in inputs.items()}
            
            with torch.no_grad():
                outputs = model(**inputs)
                logits = outputs.logits
                probabilities = torch.softmax(logits, dim=-1)[0]
                confidence = probabilities[row['label']].item()
            
            vocabulary.append({
                'word': text,
                'translation': row['translation'],
                'pronunciation': transliterate(text, language),
                'example': text,
                'confidence': round(confidence, 3)
            })
        
        return vocabulary
    
    except Exception as e:
        print(f"Error loading vocabulary: {e}")
        # Fallback to basic examples if dataset can't be loaded
        return []

def transliterate(text, language):
    """Basic transliteration for pronunciation"""
    # Simple mapping for common characters
    urdu_map = {
        'س': 's', 'ل': 'l', 'ا': 'a', 'م': 'm', 'ع': 'a',
        'ک': 'k', 'ی': 'i', 'ہ': 'h', 'ب': 'b', 'خ': 'kh',
        'ش': 'sh', 'ر': 'r', 'ی': 'y', 'ت': 't', 'ن': 'n',
        'و': 'o', 'د': 'd', 'پ': 'p', 'چ': 'ch', 'ج': 'j',
        'ف': 'f', 'ق': 'q', 'ز': 'z', 'ڑ': 'r', 'ں': 'n',
        'ے': 'e', 'ھ': 'h', 'ٹ': 't', 'ڈ': 'd', 'گ': 'g'
    }
    
    result = []
    for char in text:
        if char in urdu_map:
            result.append(urdu_map[char])
        elif char == ' ':
            result.append(' ')
    
    return ''.join(result) if result else 'pronunciation'

if __name__ == '__main__':
    # Run on localhost:5000
    # For production, use a proper WSGI server like gunicorn
    app.run(host='0.0.0.0', port=5000, debug=True)
