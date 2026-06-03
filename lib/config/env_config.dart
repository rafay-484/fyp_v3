import 'api_keys.dart';

// Safe configuration for sensitive API keys and endpoints.
//
// To use: Run flutter build/run with:
// flutter run --dart-define=GEMINI_API_KEY=your_key_here --dart-define=HUGGINGFACE_TOKEN=your_token_here
//
// For production APK:
// flutter build apk --dart-define=GEMINI_API_KEY=your_key_here --dart-define=HUGGINGFACE_TOKEN=your_token_here
class EnvConfig {
  /// Gemini API key from environment variable.
  /// Set via: flutter run --dart-define=GEMINI_API_KEY=xxx
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  /// Backward-compatible key name used by the old assistant screen.
  static const String gcpApiKey = String.fromEnvironment(
    'GCP_API_KEY',
    defaultValue: '',
  );

  /// Gemini model. Override when needed without editing source.
  static const String geminiModel = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-2.5-flash',
  );

  /// HuggingFace API token from environment variable
  /// Set via: flutter build apk --dart-define=HUGGINGFACE_TOKEN=xxx
  static const String huggingFaceToken = String.fromEnvironment(
    'HUGGINGFACE_TOKEN',
    defaultValue: '',
  );

  /// HuggingFace Model ID
  static const String huggingFaceModelId = 'RAFAY-484/Urdu-Punjabi-V2';

  /// HuggingFace Inference API URL
  static const String huggingFaceInferenceUrl =
      'https://api-inference.huggingface.co/models/RAFAY-484/Urdu-Punjabi-V2';

  /// Validate that required configuration is present
  static bool get isConfigured {
    return _hasValue(geminiApiKey) ||
        _hasValue(gcpApiKey) ||
        _hasValue(ApiKeys.geminiApiKey) ||
        _hasValue(huggingFaceToken) ||
        _hasValue(ApiKeys.huggingFaceToken);
  }

  /// Get Gemini key or throw if not configured.
  static String getGeminiApiKey() {
    final key = _normalizeKey(geminiApiKey);
    if (key.isNotEmpty) {
      return key;
    }

    final legacyKey = _normalizeKey(gcpApiKey);
    if (legacyKey.isNotEmpty) {
      return legacyKey;
    }

    final localKey = _normalizeKey(ApiKeys.geminiApiKey);
    if (localKey.isNotEmpty) {
      return localKey;
    }

    throw Exception(
      'Gemini API key not configured. '
      'Run: flutter run --dart-define=GEMINI_API_KEY=your_key_here '
      'or set lib/config/api_keys.dart',
    );
  }

  /// Get token or throw if not configured
  static String getHuggingFaceToken() {
    final key = _normalizeKey(huggingFaceToken);
    if (key.isNotEmpty) {
      return key;
    }

    final localToken = _normalizeKey(ApiKeys.huggingFaceToken);
    if (localToken.isNotEmpty) {
      return localToken;
    }

    throw Exception(
      'HuggingFace API token not configured. '
      'Run: flutter run --dart-define=HUGGINGFACE_TOKEN=your_token_here '
      'or set lib/config/api_keys.dart',
    );
  }

  static bool _hasValue(String value) {
    return _normalizeKey(value).isNotEmpty;
  }

  static String _normalizeKey(String value) {
    final key = value.trim();
    if (key.isEmpty) {
      return '';
    }

    if (key.startsWith('YOUR_')) {
      return '';
    }

    return key;
  }
}
