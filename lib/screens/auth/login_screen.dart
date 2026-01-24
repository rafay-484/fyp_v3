import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../themes/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../localization/app_strings.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMePreference();
  }

  Future<void> _loadRememberMePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStrings.enterEmail)));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await FirebaseService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (userId != null && mounted) {
        // Save Remember Me preference
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('rememberMe', _rememberMe);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Login successful!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          // Navigate to language selection
          Navigator.of(context).pushReplacementNamed('/language-selection');
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please check your credentials.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Login failed: ${e.toString()}';
        if (e.toString().contains('user-not-found')) {
          errorMessage =
              '❌ No account found with this email. Please sign up first.';
        } else if (e.toString().contains('wrong-password')) {
          errorMessage = '❌ Incorrect password. Please try again.';
        } else if (e.toString().contains('invalid-email')) {
          errorMessage = '❌ Invalid email format.';
        } else if (e.toString().contains('email-not-verified')) {
          // Show error message and navigate to verification screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '🚫 Email Not Verified!\n\nYou must verify your email before logging in.\nCheck your inbox (and spam folder) for the verification link.\n\nClick it to verify, then try logging in again.',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 7),
            ),
          );
          await Future.delayed(const Duration(seconds: 3));
          Navigator.of(context).pushReplacementNamed('/email-verification');
          return; // Exit early
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Center(
                      child: Text('📚', style: TextStyle(fontSize: 50)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Center(
                  child: Text(
                    AppStrings.login,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    AppStrings.learnUrduPunjabi,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),

                // Email Field
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter email (ای میل درج کریں)',
                    labelText: 'Email (ای میل)',
                    prefixIcon: const Icon(
                      Icons.email,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password Field
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Enter password (پاس ورڈ درج کریں)',
                    labelText: 'Password (پاس ورڈ)',
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: AppTheme.primaryGreen,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppTheme.primaryGreen,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                ),
                const SizedBox(height: 16),

                // Remember Me Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      activeColor: AppTheme.primaryGreen,
                    ),
                    const Text(
                      'Remember Me (مجھے یاد رکھیں)',
                      style: TextStyle(fontSize: 14, color: AppTheme.darkGray),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
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
                      : const Text(
                          'Sign In (داخل ہوں)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No account? (اکاؤنٹ نہیں ہے؟)',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/signup');
                      },
                      child: const Text(
                        'Sign Up (رجسٹر کریں)',
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
