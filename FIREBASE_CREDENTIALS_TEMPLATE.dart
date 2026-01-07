// TEMPLATE: Replace these placeholder values with your real Firebase credentials
// From: https://console.firebase.google.com → Your Project → Settings ⚙️

// Find your credentials at:
// 1. Project ID: Firebase Console → Settings → General tab
// 2. API Key: Firebase Console → Settings → Cloud Messaging tab
// 3. App ID: google-services.json → client[0].client_info.mobilesdk_app_id
// 4. Messaging Sender ID: google-services.json → project_info.project_number
// 5. Storage Bucket: Firebase Console → Settings → General tab

// BEFORE RUNNING THE APP:
// ✅ Create project at https://console.firebase.google.com
// ✅ Register Android app
// ✅ Download google-services.json to android/app/
// ✅ Get your real credentials from Firebase Console
// ✅ Replace the placeholder values below with your actual values

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Android Configuration
  /// Get these values from:
  /// 1. google-services.json (in android/app/)
  /// 2. Firebase Console → Settings
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_API_KEY_FROM_FIREBASE',
    appId: 'REPLACE_WITH_YOUR_APP_ID_FROM_google_services.json',
    messagingSenderId: 'REPLACE_WITH_YOUR_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_YOUR_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_YOUR_STORAGE_BUCKET',
  );

  /// iOS Configuration (if needed)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_API_KEY_FROM_FIREBASE',
    appId: 'REPLACE_WITH_YOUR_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_YOUR_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_YOUR_STORAGE_BUCKET',
  );

  /// macOS Configuration (if needed)
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_API_KEY_FROM_FIREBASE',
    appId: 'REPLACE_WITH_YOUR_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_YOUR_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_YOUR_STORAGE_BUCKET',
  );

  /// Web Configuration (if needed)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_API_KEY_FROM_FIREBASE',
    appId: 'REPLACE_WITH_YOUR_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_YOUR_PROJECT_ID',
    authDomain: 'REPLACE_WITH_YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'REPLACE_WITH_YOUR_STORAGE_BUCKET',
  );

  /// Windows Configuration (if needed)
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_API_KEY_FROM_FIREBASE',
    appId: 'REPLACE_WITH_YOUR_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_YOUR_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_YOUR_STORAGE_BUCKET',
  );

  /// Linux Configuration (if needed)
  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_API_KEY_FROM_FIREBASE',
    appId: 'REPLACE_WITH_YOUR_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_YOUR_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_YOUR_STORAGE_BUCKET',
  );
}

// HOW TO FILL IN THE VALUES:
//
// 1. Create Firebase Project:
//    Go to: https://console.firebase.google.com
//    Click "Create a project"
//    Name it: "fyp-urdu-punjabi-tutor" (or your choice)
//    Follow setup wizard
//
// 2. Add Android App:
//    Firebase Console → Add app → Select Android
//    Package name: com.example.fyp_v1
//    Download google-services.json
//    Save to: android/app/google-services.json
//
// 3. Get Your Credentials:
//    From google-services.json file:
//      - "project_number": 123456789 ← This goes in messagingSenderId
//      - "project_id": "fyp-urdu-punjabi-tutor" ← This is projectId
//      - "storage_bucket": "fyp-urdu-punjabi-tutor.appspot.com" ← storageBucket
//      - client[0].client_info.mobilesdk_app_id: "1:123456789:android:abc123..." ← appId
//      - client[0].api_key[0].current_key: "AIzaSy..." ← apiKey
//
//    From Firebase Console:
//      Settings ⚙️ → Cloud Messaging tab
//      Look for "Server API Key" or similar ← This might be your apiKey
//
// 4. Fill in all REPLACE_WITH_... values
//
// 5. Save this file
//
// 6. Run:
//    flutter clean
//    flutter pub get
//    flutter run
//
// If you see "User signed up successfully" in console → It worked! ✅
