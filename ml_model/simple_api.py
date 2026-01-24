"""
Simple Flask API for testing without loading the full model
This is a mock version for development/testing
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import random

app = Flask(__name__)
CORS(app)

print("✅ Simple API server starting...")

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'model': 'mock-api-for-testing',
        'message': 'This is a mock API for development. Deploy to Hugging Face for production.'
    })

@app.route('/detect', methods=['POST'])
def detect_language():
    """Mock language detection endpoint"""
    try:
        data = request.get_json()
        
        if not data or 'text' not in data:
            return jsonify({'error': 'Missing "text" field'}), 400
        
        text = data['text']
        
        if not text or not text.strip():
            return jsonify({'error': 'Text cannot be empty'}), 400
        
        # Simple heuristic: check for Urdu/Punjabi characters
        urdu_chars = set('اآأإئؤبپتٹثجچحخدڈذرڑزژسشصضطظعغفقکگلمنںوہھیےٰءً')
        punjabi_markers = set('ਂਃਅਆਇਈਉਊਏਐਓਔਕਖਗਘਙਚਛਜਝਞਟਠਡਢਣਤਥਦਧਨਪਫਬਭਮਯਰਲਵਸ਼ਸਹ਼ੁੂੇੈੋੌ')
        
        has_punjabi_script = any(char in punjabi_markers for char in text)
        
        if has_punjabi_script:
            prediction = 1
            language = 'punjabi'
            confidence = 0.85 + random.uniform(0, 0.15)
        else:
            prediction = 0
            language = 'urdu'
            confidence = 0.80 + random.uniform(0, 0.20)
        
        urdu_prob = confidence if language == 'urdu' else (1 - confidence)
        punjabi_prob = confidence if language == 'punjabi' else (1 - confidence)
        
        return jsonify({
            'text': text,
            'prediction': prediction,
            'language': language,
            'confidence': round(confidence, 4),
            'probabilities': {
                'urdu': round(urdu_prob, 4),
                'punjabi': round(punjabi_prob, 4)
            }
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/generate_vocabulary', methods=['POST'])
def generate_vocabulary():
    """Mock vocabulary generation endpoint"""
    try:
        data = request.get_json()
        chapter = data.get('chapter', 'chapter1')
        lesson = data.get('lesson', 'lesson1')
        target_language = data.get('language', 'urdu')
        count = data.get('count', 10)
        
        # Mock vocabulary
        sample_vocab = {
            'urdu': [
                {'word': 'سلام', 'translation': 'Hello', 'pronunciation': 'salaam'},
                {'word': 'شکریہ', 'translation': 'Thank you', 'pronunciation': 'shukriya'},
                {'word': 'کتاب', 'translation': 'Book', 'pronunciation': 'kitab'},
                {'word': 'پانی', 'translation': 'Water', 'pronunciation': 'pani'},
                {'word': 'دوست', 'translation': 'Friend', 'pronunciation': 'dost'},
            ],
            'punjabi': [
                {'word': 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ', 'translation': 'Hello', 'pronunciation': 'sat sri akal'},
                {'word': 'ਧੰਨਵਾਦ', 'translation': 'Thank you', 'pronunciation': 'dhannavaad'},
                {'word': 'ਕਿਤਾਬ', 'translation': 'Book', 'pronunciation': 'kitaab'},
                {'word': 'ਪਾਣੀ', 'translation': 'Water', 'pronunciation': 'paani'},
                {'word': 'ਦੋਸਤ', 'translation': 'Friend', 'pronunciation': 'dost'},
            ]
        }
        
        vocab_list = sample_vocab.get(target_language, sample_vocab['urdu'])[:count]
        
        return jsonify({
            'vocabulary': vocab_list,
            'count': len(vocab_list),
            'chapter': chapter,
            'lesson': lesson,
            'language': target_language
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    print("\n" + "="*60)
    print("🚀 MOCK API SERVER RUNNING")
    print("="*60)
    print("✅ Server URL: http://localhost:5000")
    print("✅ Health check: http://localhost:5000/health")
    print("✅ Language detect: POST to http://localhost:5000/detect")
    print("\n⚠️  This is a MOCK API for development only!")
    print("📝 For production, deploy the real model to Hugging Face")
    print("="*60 + "\n")
    
    app.run(host='0.0.0.0', port=5000, debug=False)
