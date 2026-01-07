import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/app_theme.dart';
import '../../providers/user_provider.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.language, size: 80, color: AppTheme.white),
              const SizedBox(height: 32),
              const Text(
                'Choose Your Language',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Which language do you want to learn?',
                style: TextStyle(fontSize: 18, color: AppTheme.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _LanguageCard(
                title: 'Urdu',
                subtitle: 'اردو - Learn Urdu language',
                flag: '🇵🇰',
                description: 'Official language of Pakistan',
                languageCode: 'urdu',
              ),
              const SizedBox(height: 16),
              _LanguageCard(
                title: 'Pakistani Punjabi',
                subtitle: 'پنجابی - Learn Punjabi language (Shahmukhi)',
                flag: '🇵🇰',
                description: 'Regional language of Punjab, Pakistan',
                languageCode: 'punjabi',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String flag;
  final String description;
  final String languageCode;

  const _LanguageCard({
    required this.title,
    required this.subtitle,
    required this.flag,
    required this.description,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Provider.of<UserProvider>(
            context,
            listen: false,
          ).setSelectedLanguage(languageCode);
          Navigator.of(context).pushReplacementNamed('/home');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 48)),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: AppTheme.primaryGreen),
            ],
          ),
        ),
      ),
    );
  }
}
