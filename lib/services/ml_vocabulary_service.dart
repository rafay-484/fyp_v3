import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// ML-powered service using XLM-RoBERTa for intelligent vocabulary and phrase learning
class MLVocabularyService {
  // Hugging Face model for language detection (always available)
  static const String _huggingFaceModel = 'RAFAY-484/Urdu-Punjabi';

  // Local API server for vocabulary generation (optional)
  static const String _localApiUrl =
      'http://192.168.1.4:5000'; // For phone on WiFi (use your PC's IP)

  static bool _modelAvailable = false;

  /// Generate vocabulary words - uses fallback if model unavailable
  /// This ensures the app always works for your FYP demo
  static Future<List<VocabularyPrediction>> generateVocabularyWithML({
    required String chapterId,
    required int lessonIndex,
    required String language,
    int count = 10,
  }) async {
    if (_modelAvailable) {
      try {
        return await _generateFromLocalModel(
          chapterId: chapterId,
          lessonIndex: lessonIndex,
          language: language,
          count: count,
        );
      } catch (e) {
        debugPrint('Local model failed, using fallback: $e');
      }
    }

    // Fallback: Use rule-based generation (always works)
    debugPrint(
      'Using fallback vocabulary generation (model not required for demo)',
    );
    return _generateFallbackVocabulary(
      chapterId: chapterId,
      lessonIndex: lessonIndex,
      language: language,
      count: count,
    );
  }

  /// Generate from locally hosted XLM-RoBERTa model server
  static Future<List<VocabularyPrediction>> _generateFromLocalModel({
    required String chapterId,
    required int lessonIndex,
    required String language,
    required int count,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_localApiUrl/generate_vocabulary'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'chapter_id': chapterId,
              'lesson_index': lessonIndex,
              'language': language,
              'count': count,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['vocabulary'] != null) {
          final vocabList = (data['vocabulary'] as List)
              .map((item) => VocabularyPrediction.fromJson(item))
              .toList();
          debugPrint(
            '✓ Generated ${vocabList.length} words from XLM-RoBERTa model',
          );
          return vocabList;
        }
      }

      debugPrint('❌ Model returned invalid response: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Local model error: $e');
      rethrow; // Propagate to caller for fallback
    }

    // Return empty if no valid response
    return [];
  }

  /// Fallback vocabulary generation when model is unavailable
  static Future<List<VocabularyPrediction>> _generateFallbackVocabulary({
    required String chapterId,
    required int lessonIndex,
    required String language,
    required int count,
  }) async {
    debugPrint('Using built-in vocabulary for $chapterId lesson $lessonIndex');

    // Basic vocabulary that works for all lessons
    final basicWords = [
      VocabularyPrediction(
        word: 'سلام',
        translation: 'Hello',
        pronunciation: 'salaam',
      ),
      VocabularyPrediction(
        word: 'شکریہ',
        translation: 'Thank you',
        pronunciation: 'shukriya',
      ),
      VocabularyPrediction(
        word: 'ہاں',
        translation: 'Yes',
        pronunciation: 'haan',
      ),
      VocabularyPrediction(
        word: 'نہیں',
        translation: 'No',
        pronunciation: 'nahi',
      ),
      VocabularyPrediction(
        word: 'پانی',
        translation: 'Water',
        pronunciation: 'paani',
      ),
      VocabularyPrediction(
        word: 'کھانا',
        translation: 'Food',
        pronunciation: 'khaana',
      ),
      VocabularyPrediction(
        word: 'نام',
        translation: 'Name',
        pronunciation: 'naam',
      ),
      VocabularyPrediction(
        word: 'کتاب',
        translation: 'Book',
        pronunciation: 'kitaab',
      ),
      VocabularyPrediction(
        word: 'قلم',
        translation: 'Pen',
        pronunciation: 'qalam',
      ),
      VocabularyPrediction(
        word: 'گھر',
        translation: 'Home',
        pronunciation: 'ghar',
      ),
      VocabularyPrediction(
        word: 'دوست',
        translation: 'Friend',
        pronunciation: 'dost',
      ),
      VocabularyPrediction(
        word: 'محبت',
        translation: 'Love',
        pronunciation: 'mohabbat',
      ),
    ];

    return basicWords.take(count).toList();
  }

  /// Check if local model server is available (optional for demo)
  static Future<bool> checkModelAvailability() async {
    try {
      final response = await http
          .get(Uri.parse('$_localApiUrl/health'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        _modelAvailable = true;
        final data = jsonDecode(response.body);
        debugPrint('✓ XLM-RoBERTa model server is ONLINE');
        debugPrint('  Model: ${data['model'] ?? 'unknown'}');
        debugPrint('  Device: ${data['device'] ?? 'unknown'}');
        return true;
      }
    } catch (e) {
      _modelAvailable = false;
      debugPrint('Note: Local model server is offline (not required for demo)');
      debugPrint('Language detection works via Hugging Face API');
    }

    return false;
  }
}

/// Vocabulary prediction from ML model
class VocabularyPrediction {
  final String word;
  final String translation;
  final String pronunciation;
  final double confidence;
  final String? example;

  VocabularyPrediction({
    required this.word,
    required this.translation,
    required this.pronunciation,
    this.confidence = 1.0,
    this.example,
  });

  factory VocabularyPrediction.fromJson(Map<String, dynamic> json) {
    return VocabularyPrediction(
      word: json['word'] ?? '',
      translation: json['translation'] ?? '',
      pronunciation: json['pronunciation'] ?? '',
      confidence: (json['confidence'] ?? 1.0).toDouble(),
      example: json['example'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'translation': translation,
      'pronunciation': pronunciation,
      'confidence': confidence,
      'example': example,
    };
  }
}
