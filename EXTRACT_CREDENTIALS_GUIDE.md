# 🔑 Firebase Credentials - Extract & Copy Guide

## Your google-services.json File

You have opened: `android/app/google-services.json`

---

## 🎯 The 5 Credential Values You Need

### Here's Your File (Annotated)

```json
{
  "project_info": {
    "project_number": "512702510637",                    ← VALUE #2: messagingSenderId
    "project_id": "fyp-urdu-punjabi-tutor",             ← VALUE #3: projectId
    "storage_bucket": "fyp-urdu-punjabi-tutor.firebasestorage.app"  ← VALUE #4: storageBucket
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:512702510637:android:ea829984f70c0ee8142aa4",  ← VALUE #1: appId
        "android_client_info": {
          "package_name": "com.example.fyp_v1"
        }
      },
      "api_key": [
        {
          "current_key": "AIzaSyAGkR0H9MxTeiEgUBGbnYpsinp5035JKVs"  ← VALUE #5: apiKey
        }
      ]
    }
  ]
}
```

---

## ✅ The 5 Values (Copy These Exact Values)

| # | Firebase Name | Your Value | Use In |
|---|---|---|---|
| 1️⃣ | `mobilesdk_app_id` | `1:512702510637:android:ea829984f70c0ee8142aa4` | `appId` |
| 2️⃣ | `project_number` | `512702510637` | `messagingSenderId` |
| 3️⃣ | `project_id` | `fyp-urdu-punjabi-tutor` | `projectId` |
| 4️⃣ | `storage_bucket` | `fyp-urdu-punjabi-tutor.firebasestorage.app` | `storageBucket` |
| 5️⃣ | `current_key` | `AIzaSyAGkR0H9MxTeiEgUBGbnYpsinp5035JKVs` | `apiKey` |

---

## 📋 Copy & Paste Ready Format

### Value #1: appId
```
1:512702510637:android:ea829984f70c0ee8142aa4
```

### Value #2: messagingSenderId
```
512702510637
```

### Value #3: projectId
```
fyp-urdu-punjabi-tutor
```

### Value #4: storageBucket
```
fyp-urdu-punjabi-tutor.firebasestorage.app
```

### Value #5: apiKey
```
AIzaSyAGkR0H9MxTeiEgUBGbnYpsinp5035JKVs
```

---

## 🔄 Where These Go

**File to Update**: `lib/firebase_options.dart`

**Location**: Look for the Android section (around line 42-50)

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'REPLACE_WITH_VALUE_#5',              ← Put apiKey here
  appId: 'REPLACE_WITH_VALUE_#1',               ← Put appId here
  messagingSenderId: 'REPLACE_WITH_VALUE_#2',   ← Put messagingSenderId here
  projectId: 'REPLACE_WITH_VALUE_#3',           ← Put projectId here
  storageBucket: 'REPLACE_WITH_VALUE_#4',       ← Put storageBucket here
);
```

---

## ✨ After Replacement

Your code should look like:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSyAGkR0H9MxTeiEgUBGbnYpsinp5035JKVs',
  appId: '1:512702510637:android:ea829984f70c0ee8142aa4',
  messagingSenderId: '512702510637',
  projectId: 'fyp-urdu-punjabi-tutor',
  storageBucket: 'fyp-urdu-punjabi-tutor.firebasestorage.app',
);
```

---

## 🎯 Step-by-Step Instructions

### Step 1: Copy Value #1 (appId)
- Find in google-services.json: `"mobilesdk_app_id": "1:512702510637:android:ea829984f70c0ee8142aa4"`
- Copy: `1:512702510637:android:ea829984f70c0ee8142aa4`

### Step 2: Copy Value #2 (messagingSenderId)
- Find in google-services.json: `"project_number": "512702510637"`
- Copy: `512702510637`

### Step 3: Copy Value #3 (projectId)
- Find in google-services.json: `"project_id": "fyp-urdu-punjabi-tutor"`
- Copy: `fyp-urdu-punjabi-tutor`

### Step 4: Copy Value #4 (storageBucket)
- Find in google-services.json: `"storage_bucket": "fyp-urdu-punjabi-tutor.firebasestorage.app"`
- Copy: `fyp-urdu-punjabi-tutor.firebasestorage.app`

### Step 5: Copy Value #5 (apiKey)
- Find in google-services.json: `"current_key": "AIzaSyAGkR0H9MxTeiEgUBGbnYpsinp5035JKVs"`
- Copy: `AIzaSyAGkR0H9MxTeiEgUBGbnYpsinp5035JKVs`

---

## 🎬 What Happens Next

1. You copy these 5 values
2. You open `lib/firebase_options.dart`
3. You replace the placeholder values with these real ones
4. You save the file
5. You run: `flutter clean && flutter pub get && flutter run -d emulator-5554`
6. **Your signup will work!** ✅

---

## ⚠️ Important Notes

- ✅ These values are **SAFE to share** (they're public API keys for frontend)
- ✅ Backend is protected by **Firestore Security Rules** (you set up later)
- ✅ API key is intentionally public (all mobile apps need it)
- ✅ Database access is controlled by rules, not the key

---

## 🔍 Visual Location in JSON File

```
google-services.json
├─ "project_info"
│  ├─ "project_number": "512702510637"              ← messagingSenderId
│  ├─ "project_id": "fyp-urdu-punjabi-tutor"        ← projectId
│  └─ "storage_bucket": "..."                       ← storageBucket
└─ "client": [
   └─ [0]
      ├─ "client_info"
      │  └─ "mobilesdk_app_id": "1:512702510637:..." ← appId
      └─ "api_key": [
         └─ [0]
            └─ "current_key": "AIzaSy..."            ← apiKey
```

---

## ✅ Ready to Go!

You have all 5 values! Now:

1. **Open**: `lib/firebase_options.dart`
2. **Find**: The Android section (lines 42-50)
3. **Replace**: The 5 placeholder values with your real values
4. **Save**: The file
5. **Run**: `flutter run -d emulator-5554`

---

## 📝 Summary Table

| Step | What | From google-services.json | To firebase_options.dart |
|------|------|--------------------------|--------------------------|
| 1 | appId | `mobilesdk_app_id` | Line ~51 |
| 2 | messagingSenderId | `project_number` | Line ~52 |
| 3 | projectId | `project_id` | Line ~53 |
| 4 | storageBucket | `storage_bucket` | Line ~54 |
| 5 | apiKey | `current_key` | Line ~50 |

**All 5 values are now in your hands!** 🎉

Next: Update `lib/firebase_options.dart` with these values.
