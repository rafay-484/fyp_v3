import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String name;
  final String selectedLanguage; // 'urdu', 'punjabi'
  final int points;
  final int level;
  final List<String> unlockedBadges;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.selectedLanguage = 'urdu',
    this.points = 0,
    this.level = 1,
    this.unlockedBadges = const [],
    required this.createdAt,
  });
}

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  User? get user => _currentUser; // Add getter for 'user'
  bool get isAuthenticated => _isAuthenticated;

  void setUser(User user) {
    _currentUser = user;
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> loadUserFromFirebase() async {
    try {
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        // Get user data from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data()!;
          _currentUser = User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            name:
                data['displayName'] ??
                firebaseUser.email?.split('@')[0] ??
                'User',
            selectedLanguage: data['selectedLanguage'] ?? 'urdu',
            points: data['totalXP'] ?? 0,
            level: ((data['totalXP'] ?? 0) / 100).floor() + 1,
            unlockedBadges: List<String>.from(data['unlockedBadges'] ?? []),
            createdAt:
                (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          );
          _isAuthenticated = true;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading user from Firebase: $e');
    }
  }

  void setSelectedLanguage(String language) {
    if (_currentUser != null) {
      _currentUser = User(
        id: _currentUser!.id,
        email: _currentUser!.email,
        name: _currentUser!.name,
        selectedLanguage: language,
        points: _currentUser!.points,
        level: _currentUser!.level,
        unlockedBadges: _currentUser!.unlockedBadges,
        createdAt: _currentUser!.createdAt,
      );
      notifyListeners();
    }
  }

  void updateLanguage(String language) {
    setSelectedLanguage(language);
  }

  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
