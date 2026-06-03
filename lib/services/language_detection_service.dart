import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/env_config.dart';

/// Detects whether a learning target is Urdu or Punjabi.
///
/// The primary path uses the project's XLM-RoBERTa Hugging Face model. If the
/// token/model is unavailable, the app falls back to deterministic script and
/// common-word rules so the assistant still works offline.
class LanguageDetectionService {
  static const String _huggingFaceModel = EnvConfig.huggingFaceModelId;
  static const String _apiEndpoint =
      'https://api-inference.huggingface.co/models/$_huggingFaceModel';

  Future<LanguageDetectionResult> detectLanguage(String text) async {
    final cleaned = text.trim();
    if (cleaned.isEmpty) {
      return LanguageDetectionResult(
        language: 'urdu',
        confidence: 0.5,
        isUrdu: true,
        source: LanguageDetectionSource.rules,
      );
    }

    try {
      return await _detectViaHuggingFace(cleaned, retry: 1);
    } catch (e) {
      debugPrint('XLM-R language detection unavailable, using rules: $e');
      return _detectViaRules(cleaned);
    }
  }

  Future<LanguageDetectionResult> _detectViaHuggingFace(
    String text, {
    int retry = 1,
  }) async {
    final response = await http
        .post(
          Uri.parse(_apiEndpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${EnvConfig.getHuggingFaceToken()}',
          },
          body: jsonEncode({'inputs': text}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 503 && retry > 0) {
      await Future.delayed(const Duration(seconds: 2));
      return _detectViaHuggingFace(text, retry: retry - 1);
    }

    if (response.statusCode != 200) {
      throw Exception('Hugging Face request failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final predictions = _extractPredictions(data);
    if (predictions.isEmpty) {
      throw Exception('No language predictions returned');
    }

    double urduScore = 0;
    double punjabiScore = 0;

    for (final prediction in predictions) {
      final label = prediction['label']?.toString().toLowerCase() ?? '';
      final score = (prediction['score'] as num?)?.toDouble() ?? 0;

      if (label == 'label_0' || label.contains('urdu')) {
        urduScore = score;
      } else if (label == 'label_1' || label.contains('punjabi')) {
        punjabiScore = score;
      }
    }

    if (urduScore == 0 && punjabiScore == 0) {
      throw Exception('Unknown prediction labels: $predictions');
    }

    final isUrdu = urduScore >= punjabiScore;
    return LanguageDetectionResult(
      language: isUrdu ? 'urdu' : 'punjabi',
      confidence: isUrdu ? urduScore : punjabiScore,
      isUrdu: isUrdu,
      source: LanguageDetectionSource.xlmRoberta,
    );
  }

  List<Map<String, dynamic>> _extractPredictions(dynamic data) {
    if (data is List && data.isNotEmpty) {
      if (data.first is List) {
        return (data.first as List)
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      if (data.first is Map) {
        return data
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }

    return const [];
  }

  LanguageDetectionResult _detectViaRules(String text) {
    final lower = text.toLowerCase();

    final urduWords = <String>[
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
      'لیے',
      'بھی',
      'aap',
      'kya',
      'kyun',
      'main',
      'hai',
      'hain',
      'urdu',
    ];

    final punjabiWords = <String>[
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
      'اوہ',
      'ایہ',
      'تسی',
      'اسی',
      'تیری',
      'میری',
      'ساڈا',
      'تہاڈا',
      'ہور',
      'کوئی',
      'جے',
      'tusi',
      'tuha',
      'tuhada',
      'sadda',
      'ki haal',
      'punjabi',
      'panjabi',
    ];

    var urduScore = 0;
    var punjabiScore = 0;

    for (final word in urduWords) {
      if (lower.contains(word.toLowerCase())) {
        urduScore++;
      }
    }

    for (final word in punjabiWords) {
      if (lower.contains(word.toLowerCase())) {
        punjabiScore++;
      }
    }

    if (_hasGurmukhi(text)) {
      punjabiScore += 4;
    }

    final isUrdu = urduScore >= punjabiScore;
    final total = urduScore + punjabiScore;
    return LanguageDetectionResult(
      language: isUrdu ? 'urdu' : 'punjabi',
      confidence: total == 0
          ? 0.5
          : ((isUrdu ? urduScore : punjabiScore) / total).clamp(0.5, 1),
      isUrdu: isUrdu,
      source: LanguageDetectionSource.rules,
    );
  }

  static bool _hasGurmukhi(String text) {
    return RegExp(r'[\u0A00-\u0A7F]').hasMatch(text);
  }

  Future<List<LanguageDetectionResult>> detectLanguageBatch(
    List<String> texts,
  ) async {
    return Future.wait(texts.map(detectLanguage));
  }
}

enum LanguageDetectionSource { xlmRoberta, rules, script }

class LanguageDetectionResult {
  final String language;
  final double confidence;
  final bool isUrdu;
  final LanguageDetectionSource source;

  LanguageDetectionResult({
    required this.language,
    required this.confidence,
    required this.isUrdu,
    this.source = LanguageDetectionSource.rules,
  });

  bool get isPunjabi => !isUrdu;

  String get displayName => isUrdu ? 'Urdu' : 'Punjabi';

  String get sourceLabel {
    switch (source) {
      case LanguageDetectionSource.xlmRoberta:
        return 'XLM-RoBERTa';
      case LanguageDetectionSource.script:
        return 'script';
      case LanguageDetectionSource.rules:
        return 'rules';
    }
  }

  @override
  String toString() {
    final percent = (confidence * 100).toStringAsFixed(1);
    return '$displayName ($percent%, $sourceLabel)';
  }
}
