import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service for detecting language (Urdu vs Punjabi) using trained XLM-RoBERTa model
class LanguageDetectionService {
  // For production, you would deploy the model to a server
  // For now, we'll use a simple rule-based approach as a fallback
  // until you set up a model inference endpoint

  static const String _apiEndpoint =
      'http://127.0.0.1:5000/detect'; // XLM-RoBERTa model API

  /// Detect if text is Urdu (0) or Punjabi (1)
  Future<LanguageDetectionResult> detectLanguage(String text) async {
    try {
      // If you have a model API endpoint, use it
      if (_apiEndpoint != 'YOUR_MODEL_API_ENDPOINT') {
        return await _detectViaAPI(text);
      }

      // Fallback: Rule-based detection
      return _detectViaRules(text);
    } catch (e) {
      debugPrint('Language detection error: $e');
      return LanguageDetectionResult(
        language: 'urdu',
        confidence: 0.5,
        isUrdu: true,
      );
    }
  }

  /// Detect language via API (when model is deployed)
  Future<LanguageDetectionResult> _detectViaAPI(String text) async {
    final response = await http.post(
      Uri.parse(_apiEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prediction = data['prediction'] as int; // 0 = Urdu, 1 = Punjabi
      final confidence = data['confidence'] as double;

      return LanguageDetectionResult(
        language: prediction == 0 ? 'urdu' : 'punjabi',
        confidence: confidence,
        isUrdu: prediction == 0,
      );
    }

    throw Exception('API request failed: ${response.statusCode}');
  }

  /// Rule-based detection (fallback)
  LanguageDetectionResult _detectViaRules(String text) {
    // Common Urdu words
    final urduWords = [
      'ہے',
      'ہیں',
      'تھا',
      'تھے',
      'کیا',
      'کے',
      'کی',
      'کو',
      'میں',
      'نے',
      'پر',
      'سے',
      'کا',
      'اور',
      'یہ',
      'وہ',
      'آپ',
      'ہم',
      'تم',
      'وہ',
      'یا',
      'لیے',
      'لئے',
      'بھی',
    ];

    // Common Punjabi words and patterns
    final punjabiWords = [
      'اے',
      'او',
      'نوں',
      'توں',
      'دا',
      'دی',
      'دے',
      'نال',
      'وچ',
      'تے',
      'کی',
      'اوہ',
      'ایہ',
      'میں',
      'تسی',
      'اسی',
      'تیری',
      'میری',
      'ساڈا',
      'تہاڈا',
      'ہور',
      'کوئی',
      'جے',
    ];

    int urduScore = 0;
    int punjabiScore = 0;

    // Count matches
    for (final word in urduWords) {
      if (text.contains(word)) urduScore++;
    }

    for (final word in punjabiWords) {
      if (text.contains(word)) punjabiScore++;
    }

    // Determine result
    final isUrdu = urduScore >= punjabiScore;
    final totalMatches = urduScore + punjabiScore;
    final confidence = totalMatches > 0
        ? (isUrdu ? urduScore : punjabiScore) / totalMatches
        : 0.5;

    return LanguageDetectionResult(
      language: isUrdu ? 'urdu' : 'punjabi',
      confidence: confidence,
      isUrdu: isUrdu,
    );
  }

  /// Batch detect languages for multiple texts
  Future<List<LanguageDetectionResult>> detectLanguageBatch(
    List<String> texts,
  ) async {
    return Future.wait(texts.map((text) => detectLanguage(text)));
  }
}

/// Result of language detection
class LanguageDetectionResult {
  final String language; // 'urdu' or 'punjabi'
  final double confidence; // 0.0 to 1.0
  final bool isUrdu;

  LanguageDetectionResult({
    required this.language,
    required this.confidence,
    required this.isUrdu,
  });

  bool get isPunjabi => !isUrdu;

  String get displayName => isUrdu ? 'اردو (Urdu)' : 'پنجابی (Punjabi)';

  @override
  String toString() =>
      '$displayName (${(confidence * 100).toStringAsFixed(1)}%)';
}
