# API اور Integrations گائیڈ

## Firebase Integration

### 1. Setup کریں

```bash
flutter pub global activate flutterfire_cli
flutterfire configure
```

### 2. Authentication

```dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign Up
  Future<UserCredential> signUp(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign In
  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign Out
  Future<void> signOut() {
    return _auth.signOut();
  }
}
```

### 3. Firestore Database

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // صارف کی ڈیٹا محفوظ کریں
  Future<void> saveUserData(String userId, Map<String, dynamic> data) {
    return _db.collection('users').doc(userId).set(data);
  }

  // صارف کی ترقی حاصل کریں
  Future<Map<String, dynamic>?> getUserProgress(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.data();
  }

  // اسباق محفوظ کریں
  Future<void> saveLessons(List<Map<String, dynamic>> lessons) {
    final batch = _db.batch();
    for (var lesson in lessons) {
      batch.set(_db.collection('lessons').doc(), lesson);
    }
    return batch.commit();
  }
}
```

## XLM-RoBERTa AI Model Integration

### 1. Flask Backend Server

```python
from flask import Flask, request, jsonify
from transformers import AutoTokenizer, AutoModelForTokenClassification, pipeline

app = Flask(__name__)

# ماڈل لوڈ کریں
tokenizer = AutoTokenizer.from_pretrained("xlm-roberta-base")
model = AutoModelForTokenClassification.from_pretrained("xlm-roberta-finetuned-urdu-punjabi")
nlp = pipeline("ner", model=model, tokenizer=tokenizer)

@app.route('/check-grammar', methods=['POST'])
def check_grammar():
    text = request.json.get('text')
    language = request.json.get('language')
    
    # نمونہ تصحیح
    result = nlp(text)
    
    return jsonify({
        'original': text,
        'errors': result,
        'corrected': correct_text(text, result)
    })

@app.route('/generate-quiz', methods=['POST'])
def generate_quiz():
    lesson = request.json.get('lesson')
    language = request.json.get('language')
    
    # AI سے سوالات بنائیں
    questions = generate_questions(lesson, language)
    
    return jsonify({
        'questions': questions
    })

def correct_text(text, errors):
    # تصحیح کی منطق
    return text

def generate_questions(lesson, language):
    # سوالات بنانے کی منطق
    return []

if __name__ == '__main__':
    app.run(debug=True, port=5000)
```

### 2. Flutter میں Integration

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class AIService {
  static const String baseUrl = 'http://localhost:5000';

  static Future<Map<String, dynamic>> checkGrammar(
    String text,
    String language,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/check-grammar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'text': text,
        'language': language,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('قواعد الفاظ کی تصحیح میں مسئلہ');
    }
  }

  static Future<List<Map<String, dynamic>>> generateQuiz(
    String lesson,
    String language,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/generate-quiz'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'lesson': lesson,
        'language': language,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['questions']);
    } else {
      throw Exception('سوالات تیار کرنے میں مسئلہ');
    }
  }
}
```

## Speech Recognition Integration

```dart
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  late stt.SpeechToText _speechToText;

  Future<void> initialize() async {
    _speechToText = stt.SpeechToText();
    await _speechToText.initialize(
      onError: (error) => print('Error: $error'),
      onStatus: (status) => print('Status: $status'),
    );
  }

  Future<String> startListening(String language) async {
    String recognizedText = '';

    if (!_speechToText.isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        _speechToText.listen(
          onResult: (result) {
            recognizedText = result.recognizedWords;
          },
          localeId: language == 'urdu' ? 'ur_PK' : 'pa_PK',
        );
      }
    }

    return recognizedText;
  }

  void stopListening() {
    if (_speechToText.isListening) {
      _speechToText.stop();
    }
  }
}
```

## Text-to-Speech Integration

```dart
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  late FlutterTts _flutterTts;

  TTSService() {
    _flutterTts = FlutterTts();
    _initialize();
  }

  Future<void> _initialize() async {
    await _flutterTts.setLanguage('ur');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
  }

  Future<void> speak(String text, String language) async {
    await _flutterTts.setLanguage(language == 'urdu' ? 'ur' : 'pa');
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
```

## Push Notifications

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // اجازت دریافت کریں
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('صارف کی اجازت دے دی');
    }

    // پیغام سننے کے لیے
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('پیغام موصول: ${message.notification?.title}');
    });
  }

  Future<String?> getDeviceToken() async {
    return await _firebaseMessaging.getToken();
  }
}
```

## Analytics Integration

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logEvent(String name, Map<String, dynamic> parameters) {
    return _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  Future<void> logLessonStart(String chapterTitle) {
    return logEvent('lesson_start', {
      'chapter': chapterTitle,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> logQuizComplete(int score, int total) {
    return logEvent('quiz_complete', {
      'score': score,
      'total': total,
      'percentage': (score / total * 100).toInt(),
    });
  }

  Future<void> logBadgeUnlocked(String badgeName) {
    return logEvent('badge_unlocked', {
      'badge': badgeName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
```

## API مثال

### قواعس الفاظ کی تصحیح

**Request:**
```json
{
  "text": "میں اردو سیکھ رہا ہوں",
  "language": "urdu"
}
```

**Response:**
```json
{
  "original": "میں اردو سیکھ رہا ہوں",
  "errors": [],
  "corrected": "میں اردو سیکھ رہا ہوں",
  "suggestions": []
}
```

### سوالات تیار کریں

**Request:**
```json
{
  "lesson": "بنیادی الفاظ",
  "language": "urdu"
}
```

**Response:**
```json
{
  "questions": [
    {
      "question": "السلام علیکم کا مطلب کیا ہے؟",
      "options": [
        "خدا حافظ",
        "السلام علیکم",
        "شکریہ",
        "براہ کرم"
      ],
      "correct": 0
    }
  ]
}
```

## نتیجہ

تمام Integrations تیار ہیں۔ Backend سروسز شامل کریں اور API کالز شروع کریں۔

---

**آخری اپڈیٹ**: اکتوبر 2025
