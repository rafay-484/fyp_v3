import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/app_theme.dart';
import '../../providers/learning_provider.dart';
import '../../providers/gamification_provider.dart';

class QuizScreen extends StatefulWidget {
  final Chapter chapter;

  const QuizScreen({Key? key, required this.chapter}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<QuizQuestion> _questions;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _showResult = false;

  final List<Map<String, dynamic>> _sampleQuestions = [
    {
      'question': 'السلام علیکم کا جواب کیا ہے؟',
      'options': ['وعلیکم السلام', 'شکریہ', 'ہاں', 'نہیں'],
      'correct': 'وعلیکم السلام',
    },
    {
      'question': 'یہ کتاب کس کی ہے؟',
      'options': ['میرے', 'تمہاری', 'اس کے', 'ان کی'],
      'correct': 'میرے',
    },
    {
      'question': 'آج کون سا دن ہے؟',
      'options': ['سوموار', 'منگل', 'بدھ', 'جمعہ'],
      'correct': 'سوموار',
    },
  ];

  @override
  void initState() {
    super.initState();
    _questions = _sampleQuestions
        .map(
          (q) => QuizQuestion(
            id: q['question'],
            question: q['question'],
            options: List<String>.from(q['options']),
            correctAnswer: q['correct'],
          ),
        )
        .toList();
  }

  void _answerQuestion(String selectedAnswer) {
    if (selectedAnswer == _questions[_currentQuestionIndex].correctAnswer) {
      setState(() {
        _score++;
      });
      Provider.of<GamificationProvider>(context, listen: false).addPoints(10);
    }

    setState(() {
      _showResult = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        if (_currentQuestionIndex < _questions.length - 1) {
          setState(() {
            _currentQuestionIndex++;
            _showResult = false;
          });
        } else {
          _showCompletionDialog();
        }
      }
    });
  }

  void _showCompletionDialog() {
    final percentage = ((_score / _questions.length) * 100).toInt();
    Provider.of<GamificationProvider>(
      context,
      listen: false,
    ).addPoints(percentage);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('مبارک ہو!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryGreen,
              child: Text(
                '$percentage%',
                style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'آپ نے $_score/${_questions.length} سوالات کے جوابات درست دیے',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('ختم کریں'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('کوئز'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Progress
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            minHeight: 6,
            backgroundColor: AppTheme.lightGreen.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.primaryGreen,
            ),
          ),
          // Question Counter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'سوال ${_currentQuestionIndex + 1}/${_questions.length}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Chip(
                  label: Text('اسکور: $_score'),
                  backgroundColor: AppTheme.lightGreen,
                ),
              ],
            ),
          ),
          // Question
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentQuestion.question,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Options
                  ...currentQuestion.options.map((option) {
                    final isCorrect = option == currentQuestion.correctAnswer;
                    final isSelected = currentQuestion.selectedAnswer == option;
                    Color backgroundColor = AppTheme.white;
                    Color borderColor = AppTheme.lightGreen;

                    if (_showResult) {
                      if (isCorrect) {
                        backgroundColor = Colors.green.withValues(alpha: 0.1);
                        borderColor = Colors.green;
                      } else if (isSelected && !isCorrect) {
                        backgroundColor = Colors.red.withValues(alpha: 0.1);
                        borderColor = Colors.red;
                      }
                    }

                    return GestureDetector(
                      onTap: _showResult
                          ? null
                          : () {
                              _answerQuestion(option);
                            },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: backgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: borderColor, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  option,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              if (_showResult)
                                Icon(
                                  isCorrect ? Icons.check : Icons.close,
                                  color: isCorrect ? Colors.green : Colors.red,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
