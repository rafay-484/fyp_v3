import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

class GrammarCheckerScreen extends StatefulWidget {
  const GrammarCheckerScreen({super.key});

  @override
  State<GrammarCheckerScreen> createState() => _GrammarCheckerScreenState();
}

class _GrammarCheckerScreenState extends State<GrammarCheckerScreen> {
  final _textController = TextEditingController();
  String _feedback = '';
  bool _isAnalyzing = false;

  void _checkGrammar() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('براہ مہربانی متن درج کریں')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _feedback = '';
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _feedback =
            'آپ کے متن کی تصحیح:\n\n✓ الفاظ درست ہیں\n✓ قواعد بہتر ہو سکتے ہیں\n\nمشورہ: "بہتر" کی جگہ "بہتری" استعمال کریں';
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قواعد الفاظ کی تصحیح')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'اپنا متن تصحیح کریں',
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(color: AppTheme.primaryGreen),
            ),
            const SizedBox(height: 8),
            Text(
              'AI-طاقت والی قواعد کی تصحیح کے ساتھ اپنی لکھائی بہتر بنائیں',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Input Area
            TextField(
              controller: _textController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'یہاں اپنا متن درج کریں...',
                labelText: 'متن',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Check Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _checkGrammar,
                icon: _isAnalyzing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(_isAnalyzing ? 'تجزیہ ہو رہا ہے...' : 'تصحیح کریں'),
              ),
            ),

            if (_feedback.isNotEmpty) ...[
              const SizedBox(height: 24),
              // Feedback Card
              Card(
                color: Colors.green.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: AppTheme.primaryGreen,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lightbulb,
                            color: AppTheme.primaryGreen,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'تصحیح',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _feedback,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Tips Section
            Text(
              'مفید نکات',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppTheme.primaryGreen),
            ),
            const SizedBox(height: 12),
            _buildTipCard('علامات کا صحیح استعمال کریں', Icons.edit),
            _buildTipCard('الفاظ کی غلط ہجے سے بچیں', Icons.spellcheck),
            _buildTipCard('جملے مکمل اور معنی خیز ہوں', Icons.text_fields),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(String tip, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Text(tip, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}
