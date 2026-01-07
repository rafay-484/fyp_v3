import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// ML-powered service using XLM-RoBERTa for intelligent vocabulary and phrase learning
/// REQUIRES trained model server to be running - NO FALLBACKS (FYP Requirement)
class MLVocabularyService {
  // Local API server for XLM-RoBERTa model - REQUIRED
  // Use 10.0.2.2 for Android emulator, or your computer's IP (192.168.x.x) for physical device
  // static const String _localApiUrl = 'http://10.0.2.2:5000';  // For emulator
  static const String _localApiUrl =
      'http://192.168.1.4:5000'; // For phone on WiFi (use your PC's IP)

  static bool _modelAvailable = false;

  /// Generate vocabulary words using XLM-RoBERTa model
  /// REQUIRES local model server - returns empty list if unavailable
  static Future<List<VocabularyPrediction>> generateVocabularyWithML({
    required String chapterId,
    required int lessonIndex,
    required String language,
    int count = 10,
  }) async {
    if (!_modelAvailable) {
      debugPrint('❌ Model server not available');
      return [];
    }

    return _generateFromLocalModel(
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
    }

    // No fallback - return empty list
    return [];
  }

  /// Check if local model server is available - REQUIRED FOR FYP
  static Future<bool> checkModelAvailability() async {
    try {
      final response = await http
          .get(Uri.parse('$_localApiUrl/health'))
          .timeout(const Duration(seconds: 5));

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
      debugPrint('❌ XLM-RoBERTa model server is OFFLINE');
      debugPrint('   Error: $e');
      debugPrint('   Start server with: python ml_model/model_api.py');
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
