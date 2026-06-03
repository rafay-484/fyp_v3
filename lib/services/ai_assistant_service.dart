import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/env_config.dart';
import 'language_detection_service.dart';

/// Extracted classifications from XLM-RoBERTa Classifier
enum AssistantIntent { translation, grammar, vocabulary }

class AIWorkflowClassification {
  final AssistantIntent intent;
  final String targetLanguage;
  final double confidenceScore;

  AIWorkflowClassification({
    required this.intent,
    required this.targetLanguage,
    required this.confidenceScore,
  });
}

/// Gemini-powered assistant for Urdu and Punjabi learning.
///
/// Workflow:
/// 1. User Input in Any Language
/// 2. XLM-RoBERTa Classifier -> Extracted Classifications (Intent, Target Language, Confidence)
/// 3. Prompt Injection Hub -> Combines Raw User Input + Classifications + PINTECH System Constraints
/// 4. Gemini LLM -> Generates user-friendly, accurate response
class AIAssistantService {
  static final LanguageDetectionService _languageDetectionService =
      LanguageDetectionService();

  static final List<Map<String, String>> _conversationHistory = [];
  static String _currentLanguage = 'urdu';

  static void setLanguage(String language) {
    final normalized = language.trim().toLowerCase();
    if (normalized == 'punjabi' || normalized == 'pa') {
      _currentLanguage = 'punjabi';
    } else {
      _currentLanguage = 'urdu';
    }
  }

  static Future<String> getResponse(String userMessage) async {
    final input = userMessage.trim();
    if (input.isEmpty) {
      return 'Please type or speak a word, sentence, or question.';
    }

    final learningTarget = _extractLearningTarget(input);
    final detection = await _detectLearningLanguage(input, learningTarget);
    _currentLanguage = detection.language;

    final intent = _classifyIntent(input);
    final classification = AIWorkflowClassification(
      intent: intent,
      targetLanguage: detection.language,
      confidenceScore: detection.confidence,
    );

    final promptInjectedText = _buildPromptInjectionHub(
      rawUserInput: input,
      classification: classification,
      learningTarget: learningTarget,
    );

    try {
      final response = await _requestGeminiResponse(
        promptInjectedHubText: promptInjectedText,
      );

      _remember('user', input);
      _remember('assistant', response);
      return response;
    } on GeminiAssistantException catch (e) {
      debugPrint('AI assistant Gemini error: ${e.message}');
      final response = _buildFallbackAssistantResponse(
        rawUserInput: input,
        classification: classification,
        learningTarget: learningTarget,
        errorMessage: e.message,
      );
      _remember('user', input);
      _remember('assistant', response);
      return response;
    } catch (e) {
      debugPrint('AI assistant Gemini error: $e');
      final response = _buildFallbackAssistantResponse(
        rawUserInput: input,
        classification: classification,
        learningTarget: learningTarget,
        errorMessage: e.toString(),
      );
      _remember('user', input);
      _remember('assistant', response);
      return response;
    }
  }

  static AssistantIntent _classifyIntent(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('translate') ||
        lower.contains('meaning') ||
        lower.contains('mean') ||
        lower.contains('say') ||
        lower.contains('tarjuma') ||
        lower.contains('translation') ||
        lower.contains('ترجمہ') ||
        lower.contains('پنجابی وچ دسو') ||
        lower.contains('اردو میں')) {
      return AssistantIntent.translation;
    }

    if (lower.contains('grammar') ||
        lower.contains('rules') ||
        lower.contains('conjugation') ||
        lower.contains('verb') ||
        lower.contains('sentence') ||
        lower.contains('correct') ||
        lower.contains('tense') ||
        lower.contains('structure') ||
        lower.contains('قواعد')) {
      return AssistantIntent.grammar;
    }

    return AssistantIntent.vocabulary;
  }

  static Future<LanguageDetectionResult> _detectLearningLanguage(
    String userMessage,
    String learningTarget,
  ) async {
    final explicitLanguage = _explicitRequestedLanguage(userMessage);
    final target = learningTarget.trim().isEmpty ? userMessage : learningTarget;

    final hasIndicScript = RegExp(
      r'[\u0600-\u06FF\u0A00-\u0A7F]',
    ).hasMatch(target);

    if (hasIndicScript) {
      return _languageDetectionService.detectLanguage(target);
    }

    if (explicitLanguage != null) {
      return LanguageDetectionResult(
        language: explicitLanguage,
        confidence: 0.94,
        isUrdu: explicitLanguage == 'urdu',
        source: LanguageDetectionSource.rules,
      );
    }

    return LanguageDetectionResult(
      language: _currentLanguage,
      confidence: 0.94,
      isUrdu: _currentLanguage == 'urdu',
      source: LanguageDetectionSource.rules,
    );
  }

  static String? _explicitRequestedLanguage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('punjabi') ||
        lower.contains('panjabi') ||
        message.contains('پنجابی') ||
        message.contains('ਪੰਜਾਬੀ')) {
      return 'punjabi';
    }

    if (lower.contains('urdu') || message.contains('اردو')) {
      return 'urdu';
    }

    return null;
  }

  static String _extractLearningTarget(String message) {
    final patterns = <RegExp>[
      RegExp(
        r'''(?:meaning|usage|use|explain|translate|pronounce|pronunciation|grammar|correct)\s+(?:of\s+)?["'`“”‘’]?(.+?)["'`“”‘’]?(?:\s+(?:in|to|into|for)\s+\w+)?$''',
        caseSensitive: false,
      ),
      RegExp(
        r'''what\s+(?:does|is)\s+["'`“”‘’]?(.+?)["'`“”‘’]?\s+(?:mean|in|to)''',
        caseSensitive: false,
      ),
      RegExp(
        r'''how\s+do\s+(?:i|you)\s+(?:say|use|write)\s+["'`“”‘’]?(.+?)["'`“”‘’]?(?:\s+in\s+\w+)?$''',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      final value = match?.group(1)?.trim();
      if (value != null && value.isNotEmpty) {
        return _cleanLearningTarget(value);
      }
    }

    return _cleanLearningTarget(message);
  }

  static String _cleanLearningTarget(String value) {
    return _stripTrailingLanguageHint(value)
        .replaceFirst(
          RegExp(
            r'^(?:this|that|sentence|phrase|word|text)\s*[:\-]?\s+',
            caseSensitive: false,
          ),
          '',
        )
        .trim();
  }

  static String _stripTrailingLanguageHint(String value) {
    return value
        .replaceFirst(
          RegExp(
            r'\s+(?:in|to|into|for)\s+(?:urdu|punjabi|panjabi|english|arabic|chinese|hindi|german|french|spanish)$',
            caseSensitive: false,
          ),
          '',
        )
        .trim();
  }

  static String _buildPromptInjectionHub({
    required String rawUserInput,
    required AIWorkflowClassification classification,
    required String learningTarget,
  }) {
    final intentStr = classification.intent.name;
    final capitalizedIntent =
        intentStr[0].toUpperCase() + intentStr.substring(1);
    final targetLangStr =
        classification.targetLanguage[0].toUpperCase() +
        classification.targetLanguage.substring(1);

    return '''
### PINTECH SYSTEM CONSTRAINTS
- You are an expert Urdu and Punjabi language learning tutor built on the PINTECH framework.
- Respond directly to the user's request with only the relevant educational answer.
- Do not mention classifier names, model names, confidence scores, or internal workflow details.
- Reply in the same language used by the user when possible, while still using native Urdu/Punjabi script, romanization, and clear translations when helpful.
- Keep the response concise, friendly, and accurate.
- Address the detected intent ($capitalizedIntent) for the target language ($targetLangStr) directly.
- Use this response style for sentence or word meaning requests:
  - First line: the user sentence/word in quotes if relevant.
  - Second line: `Means:` followed by a very short plain-language meaning.
  - Third line: `Pronunciation:` followed by romanized pronunciation in Latin script.
  - Optional lines: up to 3 very short equivalent meanings or example phrasings.
- Do not add long explanations, disclaimers, or extra commentary.
- Do not use markdown bullets, stars, or decorative punctuation.
- If the user asks in English, answer in English. If the user asks in Arabic, Chinese, German, Urdu, or Punjabi, answer in that same language.
- For Vocabulary intent: explain the meaning of words, romanized pronunciation, grammatical category, and provide at most 2 short example sentences with clear translations.
- For Translation intent: provide the direct meaning in the user's language plus pronunciation when helpful.
- For Grammar intent: explain spelling/conjugation structure, highlight rules, correct errors, and present practical guidelines.

### LEARNING TARGET
"$learningTarget"

### RAW USER INPUT
$rawUserInput
''';
  }

  static String _buildFallbackAssistantResponse({
    required String rawUserInput,
    required AIWorkflowClassification classification,
    required String learningTarget,
    required String errorMessage,
  }) {
    final targetLanguage = classification.targetLanguage;
    final targetLabel = targetLanguage == 'punjabi' ? 'Punjabi' : 'Urdu';

    final isAuthIssue =
        errorMessage.contains('401') ||
        errorMessage.toLowerCase().contains('api key') ||
        errorMessage.toLowerCase().contains('unauthorized');

    final intro = isAuthIssue
        ? 'Gemini could not authenticate right now, so I’m using offline help.'
        : 'Gemini is busy or temporarily limited, so I’m using offline help.';

    switch (classification.intent) {
      case AssistantIntent.translation:
        return [
          intro,
          'Requested translation target: $targetLabel.',
          'Text: "$learningTarget".',
          'Short help: send one short word or sentence at a time for the best result.',
          'Raw input: "$rawUserInput".',
        ].join(' ');

      case AssistantIntent.grammar:
        return [
          intro,
          'I can still help with grammar for $targetLabel.',
          'Focus on sentence order, verb agreement, and punctuation.',
          'Text: "$learningTarget".',
          'Raw input: "$rawUserInput".',
        ].join(' ');

      case AssistantIntent.vocabulary:
        return [
          intro,
          'I can still help with vocabulary for $targetLabel.',
          'Word/phrase: "$learningTarget".',
          'Try asking for meaning, pronunciation, part of speech, or an example sentence.',
          'Raw input: "$rawUserInput".',
        ].join(' ');
    }
  }

  static Future<String> _requestGeminiResponse({
    required String promptInjectedHubText,
  }) async {
    final key = EnvConfig.getGeminiApiKey();
    final model = Uri.encodeComponent(EnvConfig.geminiModel);
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$key',
    );

    final contents = <Map<String, dynamic>>[];

    for (final message in _conversationHistory.take(8)) {
      contents.add({
        'role': message['role'] == 'user' ? 'user' : 'model',
        'parts': [
          {'text': message['content'] ?? ''},
        ],
      });
    }

    contents.add({
      'role': 'user',
      'parts': [
        {'text': promptInjectedHubText},
      ],
    });

    final response = await http
        .post(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': contents,
            'generationConfig': {
              'temperature': 0.35,
              'topP': 0.9,
              'maxOutputTokens': 900,
            },
          }),
        )
        .timeout(const Duration(seconds: 25));

    if (response.statusCode != 200) {
      throw GeminiAssistantException(
        statusCode: response.statusCode,
        message: _extractGeminiErrorMessage(response.body),
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw const GeminiAssistantException(
        message: 'Gemini returned no candidates.',
      );
    }

    final candidate = candidates.first as Map<String, dynamic>;
    final content = candidate['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) {
      throw const GeminiAssistantException(
        message: 'Gemini returned no text parts.',
      );
    }

    final buffer = StringBuffer();
    for (final part in parts) {
      if (part is Map && part['text'] is String) {
        buffer.write(part['text']);
      }
    }

    final text = buffer.toString().trim();
    if (text.isEmpty) {
      throw const GeminiAssistantException(
        message: 'Gemini response text was empty.',
      );
    }

    return text;
  }

  static String _extractGeminiErrorMessage(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final error = data['error'] as Map<String, dynamic>?;
      final message = error?['message'] as String?;
      if (message != null && message.trim().isNotEmpty) {
        return message.trim();
      }
    } catch (_) {
      // Fall through to a generic message.
    }

    return 'Gemini rejected the request.';
  }

  static void _remember(String role, String content) {
    _conversationHistory.add({'role': role, 'content': content});
    if (_conversationHistory.length > 12) {
      _conversationHistory.removeRange(0, _conversationHistory.length - 12);
    }
  }

  static List<String> getSuggestions(int userLevel) {
    if (userLevel <= 3) {
      return [
        'What does "shukriya" mean in Urdu?',
        'How do I use "tusi" in Punjabi?',
        'Translate "I am learning" to Urdu',
        'Explain the sentence "main theek hoon"',
      ];
    } else if (userLevel <= 7) {
      return [
        'Explain Urdu past tense with examples',
        'Give Punjabi examples using "nal"',
        'Correct this Urdu sentence',
        'Compare Urdu and Punjabi usage of this word',
      ];
    } else {
      return [
        'Explain idiomatic usage in Punjabi',
        'Give formal and casual Urdu alternatives',
        'Break down this poetry line',
        'Create advanced practice sentences',
      ];
    }
  }

  static String getHint(String question, String language) {
    final normalized = language.toLowerCase() == 'punjabi' ? 'Punjabi' : 'Urdu';

    if (question.toLowerCase().contains('translate')) {
      return '$normalized often uses subject-object-verb word order.';
    }

    if (question.toLowerCase().contains('pronounce')) {
      return 'Break the word into syllables, then practice slowly.';
    }

    return 'Look for the main word first, then check the surrounding grammar.';
  }

  static void clearHistory() {
    _conversationHistory.clear();
  }

  static List<Map<String, String>> getHistory() {
    return List.from(_conversationHistory);
  }
}

class GeminiAssistantException implements Exception {
  final int? statusCode;
  final String message;

  const GeminiAssistantException({this.statusCode, required this.message});
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}

class LearningRecommendationService {
  static List<String> getRecommendations({
    required int completedLessons,
    required int totalPoints,
    required int streak,
    required String weakestArea,
  }) {
    final recommendations = <String>[];

    if (streak == 0) {
      recommendations.add('Start a daily learning streak today.');
    } else if (streak < 7) {
      recommendations.add('Keep going: $streak day streak. Aim for 7 days.');
    } else {
      recommendations.add('Strong work: $streak day streak.');
    }

    if (totalPoints < 100) {
      recommendations.add('Complete more lessons to earn XP points.');
    } else if (totalPoints < 500) {
      recommendations.add('Keep earning points with practice sessions.');
    }

    if (weakestArea.isNotEmpty) {
      recommendations.add('Focus on $weakestArea to improve faster.');
    }

    if (completedLessons % 5 == 0 && completedLessons > 0) {
      recommendations.add('Review with the assistant before the next lesson.');
    }

    return recommendations;
  }

  static String getDifficultyLevel(double accuracy) {
    if (accuracy >= 0.9) return 'Expert';
    if (accuracy >= 0.75) return 'Advanced';
    if (accuracy >= 0.6) return 'Intermediate';
    if (accuracy >= 0.4) return 'Beginner';
    return 'Novice';
  }
}
