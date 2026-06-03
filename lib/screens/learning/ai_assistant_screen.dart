import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../services/ai_assistant_service.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final List<Map<String, String>> _messages = <Map<String, String>>[];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();

  late final AnimationController _micAnimationController;
  late final Animation<double> _micPulseAnimation;

  bool _isListening = false;
  bool _isSending = false;
  bool _speechEnabled = false;
  bool _showGuide = true;
  String _lastFinalTranscript = '';
  String _speechLocaleId = 'en_US';

  @override
  void initState() {
    super.initState();
    _micAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _micPulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _micAnimationController, curve: Curves.easeInOut),
    );

    _messages.add(<String, String>{
      'role': 'assistant',
      'text':
          'Asalam o Alikum Ask me any word or sentence about urdu punjabi in any language',
    });

    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') && mounted) {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isListening = false);
        _showSnackBar(
          error.errorMsg.isNotEmpty
              ? error.errorMsg
              : 'Speech recognition error',
        );
      },
    );

    await _configureTtsForLanguage('en');
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _toggleListening() async {
    if (_isSending) return;

    if (_isListening) {
      await _speechToText.stop();
      if (mounted) {
        setState(() => _isListening = false);
      }
      return;
    }

    if (!_speechEnabled) {
      _showSnackBar('Speech recognition is not available on this device.');
      return;
    }

    setState(() {
      _isListening = true;
      _lastFinalTranscript = '';
    });

    await _speechToText.listen(
      localeId: _speechLocaleId,
      listenFor: const Duration(seconds: 25),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        if (!result.finalResult) {
          return;
        }

        final transcript = result.recognizedWords.trim();
        if (transcript.isEmpty || transcript == _lastFinalTranscript) {
          return;
        }

        _lastFinalTranscript = transcript;
        unawaited(_speechToText.stop());

        if (mounted) {
          setState(() => _isListening = false);
        }

        unawaited(_sendMessage(transcript));
      },
    );
  }

  Future<void> _sendTypedMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    _inputController.clear();
    await _sendMessage(text);
  }

  Future<void> _sendMessage(String text) async {
    final input = text.trim();
    if (input.isEmpty || _isSending) {
      return;
    }

    setState(() {
      _messages.add(<String, String>{'role': 'user', 'text': input});
      _isSending = true;
    });
    _scrollToBottom();

    final responseText = await AIAssistantService.getResponse(input);
    if (!mounted) return;
    final displayText = _sanitizeAssistantText(responseText);
    final spokenText = _extractSpokenText(displayText);

    setState(() {
      _messages.add(<String, String>{
        'role': 'assistant',
        'text': displayText,
      });
      _isSending = false;
    });
    _scrollToBottom();

    await _applyLanguageMode('$input\n$displayText');
    await _flutterTts.stop();
    await _flutterTts.speak(spokenText);
  }

  Future<void> _applyLanguageMode(String text) async {
    final languageCode = _detectLanguageCode(text);
    _speechLocaleId = languageCode == 'ur'
        ? 'ur_PK'
        : languageCode == 'pa'
        ? 'pa_IN'
        : languageCode == 'hi'
        ? 'hi_IN'
        : languageCode == 'ar'
        ? 'ar_SA'
        : languageCode == 'zh'
        ? 'zh_CN'
        : languageCode == 'de'
        ? 'de_DE'
        : 'en_US';
    await _configureTtsForLanguage(languageCode);
  }

  String _detectLanguageCode(String text) {
    if (RegExp(r'[\u0A00-\u0A7F]').hasMatch(text)) {
      return 'pa';
    }

    if (RegExp(r'[\u4E00-\u9FFF]').hasMatch(text)) {
      return 'zh';
    }

    if (RegExp(r'[\u0900-\u097F]').hasMatch(text)) {
      return 'hi';
    }

    final lowered = text.toLowerCase();
    if (lowered.contains('tusi') ||
        lowered.contains('tuhada') ||
        lowered.contains('sadda') ||
        lowered.contains('ki haal') ||
        lowered.contains('punjabi') ||
        lowered.contains('panjabi')) {
      return 'pa';
    }

    if (lowered.contains('aap') ||
        lowered.contains('kya') ||
        lowered.contains('kyun') ||
        lowered.contains('main') ||
        lowered.contains('urdu')) {
      return 'ur';
    }

    if (lowered.contains(' arabic ') || lowered.startsWith('arabic ')) {
      return 'ar';
    }

    if (lowered.contains(' german ') || lowered.startsWith('german ')) {
      return 'de';
    }

    if (RegExp(r'[\u0600-\u06FF]').hasMatch(text)) {
      return 'ur';
    }

    return 'en';
  }

  Future<void> _configureTtsForLanguage(String languageCode) async {
    final locale = switch (languageCode) {
      'ur' => 'ur-PK',
      'pa' => 'pa-IN',
      'hi' => 'hi-IN',
      'ar' => 'ar-SA',
      'zh' => 'zh-CN',
      'de' => 'de-DE',
      _ => 'en-US',
    };

    try {
      await _flutterTts.setLanguage(locale);
    } catch (_) {
      await _flutterTts.setLanguage('en-US');
    }

    await _flutterTts.setSpeechRate(languageCode == 'ur' ? 0.47 : 0.5);
  }

  String _sanitizeAssistantText(String text) {
    final noMarkers = text
        .replaceAll('**', '')
        .replaceAll('*', '')
        .replaceAll('\r\n', '\n');

    final lines = noMarkers.split('\n').map((line) {
      final trimmed = line.trimLeft();
      if (trimmed.startsWith('- ')) {
        return trimmed.substring(2);
      }
      if (trimmed.startsWith('• ')) {
        return trimmed.substring(2);
      }
      return trimmed;
    }).join('\n');

    return lines
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
        .trim();
  }

  String _extractSpokenText(String text) {
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    for (final line in lines) {
      final normalized = line.toLowerCase();
      if (normalized.startsWith('pronunciation:')) {
        final value = line.substring('Pronunciation:'.length).trim();
        if (value.isNotEmpty) {
          return value;
        }
      }
    }

    return text;
  }

  void _showAssistantGuide() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How to use the assistant',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Ask short, direct questions about one Urdu or Punjabi word, sentence, meaning, grammar point, or pronunciation. You can ask in English, Urdu, Punjabi, Arabic, Chinese, or German.',
              ),
              const SizedBox(height: 12),
              const Text(
                'Examples:\n'
                '• What does "Main theek hoon" mean?\n'
                '• Explain the Punjabi word "tusi".\n'
                '• Translate this Urdu sentence into Arabic.\n'
                '• How do I pronounce this line in German?',
              ),
              const SizedBox(height: 12),
              const Text(
                'Example questions:\n'
                '• What does "Main theek hoon" mean?\n'
                '• Explain the Punjabi word "tusi".\n'
                '• Translate this Urdu sentence into Arabic.',
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _clearChat() {
    AIAssistantService.clearHistory();
    setState(() {
      _messages
        ..clear()
        ..add(<String, String>{
          'role': 'assistant',
          'text':
              'Chat cleared. Ask me anything about Urdu and Punjabi in any language.',
        });
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _micAnimationController.dispose();
    _scrollController.dispose();
    _inputController.dispose();
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('AI Language Tutor'),
        actions: [
          IconButton(
            tooltip: 'How to ask',
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: _showAssistantGuide,
          ),
          IconButton(
            tooltip: 'Clear chat',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _clearChat,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_showGuide)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1D2633)
                        : const Color(0xFFF2F6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF4D5B70)
                          : const Color(0xFFCBD7FF),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.tips_and_updates_rounded,
                            size: 18,
                            color: Color(0xFF2F6BFF),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ask one short question at a time',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: 'Dismiss',
                            onPressed: () {
                              setState(() {
                                _showGuide = false;
                              });
                            },
                            icon: const Icon(Icons.close_rounded, size: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Examples: What does "Main theek hoon" mean? | Explain this Punjabi sentence | Translate this Urdu line to Arabic',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_showGuide) const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _ChatBubble(
                    text: message['text'] ?? '',
                    isUser: message['role'] == 'user',
                  );
                },
              ),
            ),
            if (_isSending)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedBuilder(
                    animation: _micPulseAnimation,
                    builder: (context, child) {
                      final scale = _isListening
                          ? _micPulseAnimation.value
                          : 1.0;
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: IconButton.filled(
                      tooltip: _isListening ? 'Stop listening' : 'Speak',
                      onPressed: _toggleListening,
                      icon: Icon(
                        _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      minLines: 1,
                      maxLines: 4,
                      enabled: !_isSending,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendTypedMessage(),
                      decoration: InputDecoration(
                        hintText: _isListening
                            ? 'Listening...'
                            : 'Ask meaning, usage, grammar, or translation',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    tooltip: 'Send',
                    onPressed: _isSending ? null : _sendTypedMessage,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const _ChatBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.84,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF2F6BFF) : const Color(0xFFF2F6FF),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Directionality(
          textDirection: _isRtl(text) ? TextDirection.rtl : TextDirection.ltr,
          child: Text(
            text,
            style: TextStyle(
              color: isUser ? Colors.white : const Color(0xFF1C2430),
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  static bool _isRtl(String value) {
    return RegExp(r'[\u0590-\u08FF]').hasMatch(value);
  }
}
