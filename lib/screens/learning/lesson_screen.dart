import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/app_theme.dart';
import '../../providers/learning_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/content_generation_service.dart' as content;
import '../../services/ml_vocabulary_service.dart';
import '../../services/voice_service.dart';

class LessonScreen extends StatefulWidget {
  final Chapter chapter;
  final int lessonIndex;

  const LessonScreen({super.key, required this.chapter, this.lessonIndex = 0});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _currentStep = 0;
  List<LessonStep> _lessonSteps = [];
  bool _isLoading = true;
  int _score = 0;
  String? _selectedAnswer;
  bool _showFeedback = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final language = userProvider.currentUser?.selectedLanguage ?? 'urdu';

    try {
      // Generate vocabulary using ML model (Hugging Face or local)
      final mlVocabulary = await MLVocabularyService.generateVocabularyWithML(
        chapterId: widget.chapter.id,
        lessonIndex: widget.lessonIndex,
        language: language,
        count: 12,
      );

      // Build lesson steps from generated vocabulary
      final steps = <LessonStep>[];

      print('✓ Generated ${mlVocabulary.length} vocabulary items');

      // Add vocabulary cards from ML model
      for (var mlWord in mlVocabulary) {
        steps.add(
          LessonStep(
            type: StepType.vocabulary,
            vocabulary: content.VocabularyWord(
              word: mlWord.word,
              translation: mlWord.translation,
              pronunciation: mlWord.pronunciation,
              example: mlWord.example ?? mlWord.word,
              exampleTranslation: mlWord.translation,
            ),
          ),
        );
      }

      // Add sentence practice
      final wordsForSentences = mlVocabulary.take(4).toList();
      for (var mlWord in wordsForSentences) {
        steps.add(
          LessonStep(
            type: StepType.sentencePractice,
            sentence: content.PracticeSentence(
              original: '${mlWord.word} - ${mlWord.translation}',
              translation: 'Practice: ${mlWord.translation}',
              pronunciation: mlWord.pronunciation,
              difficulty: 'easy',
            ),
          ),
        );
      }

      // Add quiz questions
      final wordsForQuiz = mlVocabulary.take(6).toList();
      for (int i = 0; i < wordsForQuiz.length && i < 4; i++) {
        final correctWord = wordsForQuiz[i];
        final otherWords = mlVocabulary
            .where((w) => w != correctWord)
            .take(3)
            .toList();

        steps.add(
          LessonStep(
            type: StepType.quiz,
            quiz: content.QuizQuestion(
              question:
                  'What does "${correctWord.translation}" mean in ${language == 'urdu' ? 'Urdu' : 'Punjabi'}?',
              options: [
                correctWord.word,
                if (otherWords.isNotEmpty) otherWords[0].word,
                if (otherWords.length > 1) otherWords[1].word,
                if (otherWords.length > 2) otherWords[2].word,
              ],
              correctAnswer: 0,
              explanation:
                  '${correctWord.word} (${correctWord.pronunciation}) means ${correctWord.translation}',
            ),
          ),
        );
      }

      setState(() {
        _lessonSteps = steps;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ ML Model Error: $e');
      if (mounted) {
        _showModelError('Failed to connect to XLM-RoBERTa model: $e');
      }
      setState(() => _isLoading = false);
    }
  }

  void _showModelRequiredError() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.red, size: 32),
            SizedBox(width: 12),
            Text('Model Server Required'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'XLM-RoBERTa model server is not running.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('This FYP requires the trained ML model to function.'),
            SizedBox(height: 12),
            Text(
              'To start the model server:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('1. Open terminal in ml_model folder'),
            Text('2. Run: python model_api.py'),
            Text('3. Wait for "Model loaded successfully"'),
            Text('4. Restart this lesson'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Exit lesson screen
            },
            child: const Text('Go Back'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadLesson(); // Retry
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showModelError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppTheme.orange, size: 28),
            SizedBox(width: 12),
            Text('Model Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Go Back'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadLesson();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _getTopicForChapter(String chapterId) {
    // Map chapter IDs to topics
    if (chapterId.contains('_ch1')) return 'basics';
    if (chapterId.contains('_ch2')) return 'conversation';
    if (chapterId.contains('_ch3')) return 'grammar';
    if (chapterId.contains('_ch4')) return 'travel';
    if (chapterId.contains('_ch5')) return 'food';
    if (chapterId.contains('_ch6')) return 'health';
    if (chapterId.contains('_ch7')) return 'education';
    if (chapterId.contains('_ch8')) return 'work';
    if (chapterId.contains('_ch9')) return 'technology';
    if (chapterId.contains('_ch10')) return 'culture';
    return 'basics';
  }

  void _nextStep() {
    if (_currentStep < _lessonSteps.length - 1) {
      setState(() {
        _currentStep++;
        _selectedAnswer = null;
        _showFeedback = false;
      });
    } else {
      _completeLesson();
    }
  }

  void _completeLesson() {
    final gamification = Provider.of<GamificationProvider>(
      context,
      listen: false,
    );
    final learningProvider = Provider.of<LearningProvider>(
      context,
      listen: false,
    );
    final earnedXP = (_score / _lessonSteps.length * 100).round();

    gamification.addPoints(earnedXP);
    gamification.completeLesson(); // Mark lesson as completed
    gamification.updateDailyStreak(); // Update streak

    // Mark this specific lesson as completed in the chapter
    learningProvider.markLessonCompleted(widget.chapter.id, widget.lessonIndex);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber, size: 32),
            SizedBox(width: 12),
            Text('Congratulations! 🎉'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Lesson Completed!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryGreen,
                    AppTheme.primaryGreen.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'XP Earned',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '+$earnedXP',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Score: $_score/${_lessonSteps.length}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Back to Chapters'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final language = userProvider.currentUser?.selectedLanguage ?? 'urdu';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapter.title),
        actions: [
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  '${_currentStep + 1}/${_lessonSteps.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lessonSteps.isEmpty
          ? const Center(child: Text('No content available'))
          : _buildCurrentStep(language),
    );
  }

  Widget _buildCurrentStep(String language) {
    final step = _lessonSteps[_currentStep];

    switch (step.type) {
      case StepType.vocabulary:
        return _buildVocabularyCard(step.vocabulary!, language);
      case StepType.sentencePractice:
        return _buildSentencePractice(step.sentence!, language);
      case StepType.quiz:
        return _buildQuiz(step.quiz!);
    }
  }

  Widget _buildVocabularyCard(content.VocabularyWord word, String language) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.3, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Padding(
        key: ValueKey(_currentStep),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // English Translation (Primary - for English speakers)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryGreen,
                    AppTheme.primaryGreen.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'English Meaning',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    word.translation,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Target Language Word Card
            Card(
              elevation: 8,
              shadowColor: AppTheme.primaryGreen.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Text(
                      language == 'urdu' ? 'Urdu' : 'Punjabi',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      word.word,
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.volume_up,
                          size: 32,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      onPressed: () {
                        VoiceService.speak(
                          word.word,
                          language == 'urdu' ? 'ur-PK' : 'pa-IN',
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        word.pronunciation,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Example Section
            Card(
              color: AppTheme.lightGreen.withOpacity(0.3),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.orange[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Example Usage',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      word.example,
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        word.exampleTranslation,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _score++);
                  _nextStep();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(18),
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentencePractice(
    content.PracticeSentence sentence,
    String language,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'ترجمہ کریں:',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Text(
                    sentence.original,
                    style: const TextStyle(fontSize: 32),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  IconButton(
                    icon: const Icon(
                      Icons.volume_up,
                      size: 40,
                      color: AppTheme.primaryGreen,
                    ),
                    onPressed: () {
                      VoiceService.speak(
                        sentence.original,
                        language == 'urdu' ? 'ur-PK' : 'pa-IN',
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    sentence.pronunciation,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (_showFeedback)
            Card(
              color: AppTheme.accentGreen.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.primaryGreen,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sentence.translation,
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (!_showFeedback) {
                  setState(() {
                    _showFeedback = true;
                    _score++;
                  });
                } else {
                  _nextStep();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: Text(
                _showFeedback ? 'اگلا' : 'جواب دیکھیں',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuiz(content.QuizQuestion quiz) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text(
            quiz.question,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: quiz.options.length,
              itemBuilder: (context, index) {
                final option = quiz.options[index];
                final isSelected = _selectedAnswer == option;
                final isCorrectAnswer = index == quiz.correctAnswer;

                Color? cardColor;
                if (_showFeedback) {
                  if (isCorrectAnswer) {
                    cardColor = Colors.green.withOpacity(0.3);
                  } else if (isSelected && !isCorrectAnswer) {
                    cardColor = Colors.red.withOpacity(0.3);
                  }
                } else if (isSelected) {
                  cardColor = AppTheme.lightGreen.withOpacity(0.5);
                }

                return Card(
                  color: cardColor,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    title: Text(option, style: const TextStyle(fontSize: 20)),
                    trailing: _showFeedback && isCorrectAnswer
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : _showFeedback && isSelected && !isCorrectAnswer
                        ? const Icon(Icons.cancel, color: Colors.red)
                        : null,
                    onTap: _showFeedback
                        ? null
                        : () {
                            setState(() => _selectedAnswer = option);
                          },
                  ),
                );
              },
            ),
          ),
          if (_showFeedback)
            Card(
              color: _isCorrect
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      _isCorrect ? Icons.check_circle : Icons.info,
                      color: _isCorrect ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        quiz.explanation,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedAnswer == null
                  ? null
                  : () {
                      if (!_showFeedback) {
                        final correct =
                            quiz.options[quiz.correctAnswer] == _selectedAnswer;
                        setState(() {
                          _showFeedback = true;
                          _isCorrect = correct;
                          if (correct) _score++;
                        });
                      } else {
                        _nextStep();
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey,
              ),
              child: Text(
                _showFeedback ? 'اگلا' : 'جمع کرائیں',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum StepType { vocabulary, sentencePractice, quiz }

class LessonStep {
  final StepType type;
  final content.VocabularyWord? vocabulary;
  final content.PracticeSentence? sentence;
  final content.QuizQuestion? quiz;

  LessonStep({required this.type, this.vocabulary, this.sentence, this.quiz});
}
