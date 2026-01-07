import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/home_screen.dart';
import 'screens/learning/ai_assistant_screen.dart';
import 'screens/learning/language_selection_screen.dart';
import 'providers/user_provider.dart';
import 'providers/learning_provider.dart';
import 'providers/gamification_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/adaptive_learning_provider.dart';
import 'services/adaptive_quiz_service.dart';
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and WAIT for it to complete
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✓ Firebase initialized successfully');
  } catch (e) {
    print('✗ Firebase initialization error: $e');
  }

  // Start app after Firebase is ready
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LearningProvider()),
        ChangeNotifierProvider(create: (_) => GamificationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AdaptiveQuizService()),
        ChangeNotifierProvider(create: (_) => AdaptiveLearningProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Urdu & Punjabi Tutor',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const SplashScreen(),
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignupScreen(),
              '/email-verification': (context) =>
                  const EmailVerificationScreen(),
              '/language-selection': (context) =>
                  const LanguageSelectionScreen(),
              '/home': (context) => const HomeScreen(),
              '/ai-assistant': (context) => const AIAssistantScreen(),
            },
          );
        },
      ),
    );
  }
}
