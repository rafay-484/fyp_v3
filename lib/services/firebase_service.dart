import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize Firebase
  static Future<void> initialize() async {
    try {
      // Firebase is already initialized by platform channel
      print('Firebase initialized successfully');
    } catch (e) {
      print('Firebase initialization error: $e');
    }
  }

  /// Sign up user with email and password
  static Future<String?> signUp(String email, String password) async {
    try {
      // Check if email is valid format
      if (!email.contains('@')) {
        print('Invalid email format');
        return null;
      }

      // Check password length
      if (password.length < 6) {
        print('Password must be at least 6 characters');
        return null;
      }

      // Create user with just email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Wait a moment for Firebase to complete registration
      await Future.delayed(const Duration(milliseconds: 500));

      final user = userCredential.user;
      if (user == null) {
        print('User creation failed - no user returned');
        return null;
      }

      // Send email verification
      await user.sendEmailVerification();
      print('Verification email sent to ${user.email}');

      // Create user document in Firestore
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'emailVerified': false,
          'selectedLanguage': 'urdu',
          'totalPoints': 0,
          'currentLevel': 1,
          'lessonsCompleted': 0,
          'quizzesAttempted': 0,
          'accuracy': 0.0,
        });
      } catch (firestoreError) {
        print('Firestore error (user still created): $firestoreError');
      }

      print('User signed up successfully: ${user.uid}');
      // Don't sign out - keep user signed in to verify email
      return user.uid;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      throw Exception(e.code);
    } catch (e) {
      print('Unexpected error during signup: $e');
      // If error contains "List<Object?>" then user was actually created
      if (e.toString().contains("List<Object?>")) {
        print('Type casting error but user might be created - checking...');
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          print(
            'User was created successfully despite error: ${currentUser.uid}',
          );
          return currentUser.uid;
        }
      }
      throw Exception('signup-failed');
    }
  }

  /// Sign in user with email and password
  static Future<String?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Wait a moment for Firebase to complete
      await Future.delayed(const Duration(milliseconds: 500));

      final user = userCredential.user;
      if (user == null) {
        print('Sign in failed - no user returned');
        return null;
      }

      // Reload user to get latest emailVerified status from Firebase
      await user.reload();
      final refreshedUser = _auth.currentUser;

      // Check if email is verified BEFORE allowing login
      if (refreshedUser != null && !refreshedUser.emailVerified) {
        print('Email not verified for user: ${user.uid}');
        // Keep user signed in but throw error to show verification screen
        throw Exception('email-not-verified');
      }

      // Update Firestore verification status
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'emailVerified': true,
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Failed to update verification status: $e');
      }

      print('User signed in successfully: ${user.uid}');
      return user.uid;
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.code} - ${e.message}');
      throw Exception(e.code);
    } catch (e) {
      print('Sign in error: $e');
      // If error contains "List<Object?>" then user was actually signed in
      if (e.toString().contains("List<Object?>")) {
        print('Type casting error but user might be signed in - checking...');
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          print(
            'User signed in successfully despite error: ${currentUser.uid}',
          );
          return currentUser.uid;
        }
      }
      throw Exception('signin-failed');
    }
  }

  /// Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Check if current user's email is verified
  static bool isEmailVerified() {
    final user = _auth.currentUser;
    return user?.emailVerified ?? false;
  }

  /// Send email verification
  static Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        print('Verification email sent');
      }
    } catch (e) {
      print('Error sending verification email: $e');
      throw Exception('verification-email-failed');
    }
  }

  /// Reload user to check email verification status
  static Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      print('Error reloading user: $e');
    }
  }

  /// Save user progress
  static Future<void> saveProgress(
    String userId,
    Map<String, dynamic> progress,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'totalPoints': progress['totalPoints'] ?? 0,
        'currentLevel': progress['currentLevel'] ?? 1,
        'lessonsCompleted': progress['lessonsCompleted'] ?? 0,
        'quizzesAttempted': progress['quizzesAttempted'] ?? 0,
        'accuracy': progress['accuracy'] ?? 0.0,
        'lastUpdated': DateTime.now(),
      });
    } catch (e) {
      print('Save progress error: $e');
    }
  }

  /// Get user progress
  static Future<Map<String, dynamic>?> getProgress(String userId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Get progress error: $e');
      return null;
    }
  }

  /// Sign out user
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  /// Check if user is authenticated
  static bool isUserAuthenticated() {
    return _auth.currentUser != null;
  }

  /// Reset password
  static Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Reset password error: $e');
      return false;
    }
  }
}
