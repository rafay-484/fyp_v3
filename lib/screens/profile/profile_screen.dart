import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../themes/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/firebase_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingImage = false;

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return;

      setState(() => _isUploadingImage = true);

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.currentUser!.id;

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('$userId.jpg');

      await storageRef.putFile(File(image.path));
      final downloadUrl = await storageRef.getDownloadURL();

      // Update user profile
      await userProvider.updateProfileImage(downloadUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // Load user data if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.currentUser == null) {
        userProvider.loadUserFromFirebase();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('میرا پروفائل'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseService.signOut();
              if (mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          if (userProvider.currentUser == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryGreen),
                  SizedBox(height: 16),
                  Text('Loading profile...'),
                ],
              ),
            );
          }

          return Consumer<GamificationProvider>(
            builder: (context, gamification, _) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile Header
                    Container(
                      color: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          // Avatar with Upload Button
                          Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child:
                                      userProvider
                                              .currentUser!
                                              .profileImageUrl !=
                                          null
                                      ? Image.network(
                                          userProvider
                                              .currentUser!
                                              .profileImageUrl!,
                                          fit: BoxFit.cover,
                                          loadingBuilder:
                                              (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Container(
                                                  color: AppTheme.accentGreen,
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2,
                                                        ),
                                                  ),
                                                );
                                              },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  color: AppTheme.accentGreen,
                                                  child: Center(
                                                    child: Text(
                                                      userProvider
                                                          .currentUser!
                                                          .name[0]
                                                          .toUpperCase(),
                                                      style: const TextStyle(
                                                        fontSize: 50,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppTheme.white,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                        )
                                      : Container(
                                          color: AppTheme.accentGreen,
                                          child: Center(
                                            child: Text(
                                              userProvider.currentUser!.name[0]
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 50,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              // Edit Button
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _isUploadingImage
                                      ? null
                                      : _pickAndUploadImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: _isUploadingImage
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppTheme.primaryGreen,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.camera_alt,
                                            color: AppTheme.primaryGreen,
                                            size: 20,
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            userProvider.currentUser!.name,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(color: AppTheme.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            userProvider.currentUser!.email,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.accentGreen),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Stats
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildStatCard(
                            'لیول',
                            gamification.currentLevel.toString(),
                            '🎯',
                            context,
                          ),
                          const SizedBox(width: 16),
                          _buildStatCard(
                            'پوائنٹس',
                            gamification.totalPoints.toString(),
                            '⭐',
                            context,
                          ),
                          const SizedBox(width: 16),
                          _buildStatCard(
                            'سٹریک',
                            gamification.streak.toString(),
                            '🔥',
                            context,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Progress
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'اگلی لیول تک پوائنٹس',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                '${gamification.pointsForNextLevel} باقی',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value:
                                  gamification.totalPoints /
                                  gamification.pointsForNextLevel,
                              minHeight: 8,
                              backgroundColor: AppTheme.lightGreen.withValues(
                                alpha: 0.3,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Badges Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'حاصل شدہ بیج',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: AppTheme.primaryGreen),
                          ),
                          const SizedBox(height: 12),
                          if (gamification.unlockedBadges.isEmpty)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Center(
                                  child: Text(
                                    'ابھی کوئی بیج حاصل نہیں کیا',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            )
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 1,
                                  ),
                              itemCount: gamification.unlockedBadges.length,
                              itemBuilder: (context, index) {
                                final badge =
                                    gamification.unlockedBadges[index];
                                return _buildBadgeCard(badge, context);
                              },
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Settings
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ترتیبات',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: AppTheme.primaryGreen),
                          ),
                          const SizedBox(height: 12),
                          _buildEmailVerificationStatus(context),
                          const SizedBox(height: 8),
                          _buildThemeToggle(context),
                          const SizedBox(height: 8),
                          _buildLanguageSwitcher(context, userProvider),
                          const SizedBox(height: 8),
                          _buildSettingsTile(
                            'AI اسسٹنٹ 🤖',
                            Icons.smart_toy,
                            () {
                              Navigator.pushNamed(context, '/ai-assistant');
                            },
                            context,
                          ),
                          _buildSettingsTile(
                            'ہدایات',
                            Icons.info,
                            () {},
                            context,
                          ),
                          _buildSettingsTile(
                            'رائے دیں',
                            Icons.feedback,
                            () {},
                            context,
                          ),
                          _buildSettingsTile(
                            'شرائط و ضوابط',
                            Icons.description,
                            () {},
                            context,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String emoji,
    BuildContext context,
  ) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeCard(dynamic badge, BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(badge.icon, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              badge.name,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    IconData icon,
    VoidCallback onTap,
    BuildContext context,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryGreen),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildEmailVerificationStatus(BuildContext context) {
    final isVerified = FirebaseService.isEmailVerified();
    return Card(
      color: isVerified
          ? AppTheme.lightGreen.withValues(alpha: 0.2)
          : Colors.orange.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isVerified ? Icons.verified : Icons.warning,
              color: isVerified ? AppTheme.primaryGreen : Colors.orange,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isVerified ? 'ای میل تصدیق شدہ ✓' : 'ای میل تصدیق باقی',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (!isVerified)
                    const Text(
                      'اپنی ای میل چیک کریں',
                      style: TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
            if (!isVerified)
              TextButton(
                onPressed: () async {
                  try {
                    await FirebaseService.sendEmailVerification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تصدیقی ای میل بھیج دی گئی!'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('خرابی: ${e.toString()}')),
                      );
                    }
                  }
                },
                child: const Text('دوبارہ بھیجیں'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Card(
          child: SwitchListTile(
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: AppTheme.primaryGreen,
            ),
            title: const Text(
              'ڈارک موڈ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              themeProvider.isDarkMode ? 'آن' : 'آف',
              style: const TextStyle(fontSize: 12),
            ),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
            activeThumbColor: AppTheme.primaryGreen,
          ),
        );
      },
    );
  }

  Widget _buildLanguageSwitcher(
    BuildContext context,
    UserProvider userProvider,
  ) {
    final currentLanguage =
        userProvider.currentUser?.selectedLanguage ?? 'urdu';
    final languageDisplay = currentLanguage == 'urdu' ? 'اردو' : 'پنجابی';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppTheme.primaryGreen.withOpacity(0.1),
      child: ListTile(
        leading: const Icon(Icons.language, color: AppTheme.primaryGreen),
        title: Text(
          'زبان تبدیل کریں',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Current: $languageDisplay'),
        trailing: const Icon(Icons.swap_horiz, color: AppTheme.primaryGreen),
        onTap: () {
          _showLanguageDialog(context, userProvider, currentLanguage);
        },
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    UserProvider userProvider,
    String currentLanguage,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('زبان منتخب کریں'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇵🇰', style: TextStyle(fontSize: 32)),
              title: const Text('Urdu'),
              subtitle: const Text('اردو - Official language'),
              selected: currentLanguage == 'urdu',
              selectedTileColor: AppTheme.primaryGreen.withOpacity(0.1),
              onTap: () {
                userProvider.setSelectedLanguage('urdu');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('زبان اردو میں تبدیل ہو گئی')),
                );
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Text('🇵🇰', style: TextStyle(fontSize: 32)),
              title: const Text('Pakistani Punjabi'),
              subtitle: const Text('پنجابی - Shahmukhi script'),
              selected: currentLanguage == 'punjabi',
              selectedTileColor: AppTheme.primaryGreen.withOpacity(0.1),
              onTap: () {
                userProvider.setSelectedLanguage('punjabi');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('زبان پنجابی میں تبدیل ہو گئی')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بند کریں'),
          ),
        ],
      ),
    );
  }
}
