import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../themes/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    // Brief delay to show splash
    await Future.delayed(const Duration(milliseconds: 800), () {});

    if (!mounted) return;

    try {
      // Firebase is already initialized in main(), safe to use now
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        Navigator.of(context).pushReplacementNamed('/language-selection');
      } else if (user != null && !user.emailVerified) {
        Navigator.of(context).pushReplacementNamed('/email-verification');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '📚',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'اردو اور پنجابی ٹیوٹر',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Urdu & Punjabi Tutor',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.accentGreen,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 100),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
              strokeWidth: 3,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
