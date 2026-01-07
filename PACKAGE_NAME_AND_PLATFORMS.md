# 📱 Package Name & Platforms Quick Reference

## Package Name

**Your Current Package Name**: `com.example.fyp_v1`

**Location**: `android/app/build.gradle.kts` (line 9)

### What It Is
- **Unique identifier** for your app
- **Used for**: Google Play Store, Firebase, app installation
- **Format**: `com.company.appname` (reverse domain notation)
- **Example**: `com.google.android.gm` (Gmail), `com.whatsapp`

### Your Package Breakdown
```
com.example.fyp_v1
├─ com      → Domain extension
├─ example  → Company name (you can change this)
└─ fyp_v1   → App name
```

### Change It (Optional)
Replace `com.example.fyp_v1` with something like:
- `com.rafay.fyp_v1`
- `com.fyptutor.app`
- `com.urdu.punjabi.tutor`

---

## 🚀 Running on Platforms

### Android ✅ (You Can Do This Now!)

**On Emulator:**
```bash
flutter run -d emulator-5554
```

**On Physical Phone:**
1. Enable USB Debugging (Settings → Developer Options)
2. Connect via USB cable
3. Run: `flutter run`

**Build APK to Share:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk (50 MB)
```

---

### iOS ❌ (Requires Mac)

**Requirements:**
- 🍎 macOS computer (iPad/iPhone dev only works on Mac)
- ❌ NOT possible on Windows or Linux

**When You Have a Mac:**
```bash
flutter run -d "iPhone Simulator"
```

**Alternatives (Cloud Build):**
- EAS Build (by Expo): `eas build --platform ios`
- CodeMagic: Cloud-based iOS builds
- GitHub Actions: CI/CD pipeline

---

## 📊 Current Setup Status

```
Your System: Windows
╔════════════════════════════════════════╗
║  Platform    │ Status    │ What You Can Do
╠════════════════════════════════════════╣
║  Android     │ ✅ Ready  │ Run now on emulator or phone
║  iOS         │ ❌ Mac    │ Need Mac or cloud build service
║  Web         │ ✅ Ready  │ flutter run -d chrome
║  Windows     │ ✅ Ready  │ flutter run -d windows
╚════════════════════════════════════════╝
```

---

## 🔧 Essential Commands

### List All Devices
```bash
flutter devices
```

**Output**:
```
emulator-5554  - Android Emulator (Android 16)
windows        - Windows Desktop
chrome         - Web Browser
```

### Run on Specific Device
```bash
flutter run -d emulator-5554          # Android Emulator
flutter run -d windows                # Windows Desktop
flutter run -d chrome                 # Web Browser
```

### Start Emulator
```bash
flutter emulators --launch emulator-5554
```

### Stop Running App
```
Press: q (in terminal)
Or: Ctrl+C
```

### Build APK (Shareable)
```bash
# Debug build
flutter build apk --debug

# Release build (smaller, optimized)
flutter build apk --release
```

---

## ⚡ Hot Reload vs Hot Restart

| Command | Key | Speed | Effect |
|---------|-----|-------|--------|
| Hot Reload | `r` | 1 sec | Update UI, keep state |
| Hot Restart | `R` | 5 sec | Restart app, keep emulator |
| Full Rebuild | Ctrl+C + run | 2 min | Complete rebuild |

---

## 🎯 Firebase Config for Both Platforms

### Android (Already Set Up ✅)
- **Package Name**: `com.example.fyp_v1`
- **Config File**: `android/app/google-services.json`
- **Status**: Ready (you need to download from Firebase Console)

### iOS (When You Have a Mac)
- **Bundle ID**: `com.example.fyp_v1` (must match Android)
- **Config File**: `ios/Runner/GoogleService-Info.plist`
- **Status**: Pending (download when ready)

---

## 📝 File Locations

| File | Location | Purpose |
|------|----------|---------|
| Android Package | `android/app/build.gradle.kts` | App ID for Android |
| Android Config | `android/app/google-services.json` | Firebase for Android |
| iOS Config | `ios/Runner/GoogleService-Info.plist` | Firebase for iOS (needs Mac) |
| Flutter Settings | `pubspec.yaml` | App metadata |

---

## 🎬 Quick Start: Run Your App Now!

```bash
cd c:\Users\Dell\projects\fyp_v1

# Make sure Firebase credentials are set first!
# (See: FIREBASE_SETUP_QUICK_GUIDE.md)

# Make sure emulator is running
flutter emulators --launch emulator-5554

# Run the app
flutter run -d emulator-5554

# Once running:
# - Press 'r' to hot reload
# - Press 'R' to hot restart
# - Press 'q' to quit
```

---

## 🍎 iOS Setup Later (When You Get Mac)

```bash
# On Mac:
cd path/to/your/project

# Download iOS Firebase config
# Firebase Console → Add App → iOS → Download GoogleService-Info.plist
# → Drag into Xcode at ios/Runner/

# Install iOS dependencies
flutter pub get

# Run on iOS Simulator
flutter run -d "iPhone 15"
```

---

## 📱 Testing Your App

### Test on Android Emulator (Now!)
```bash
flutter run -d emulator-5554
```
✅ You can do this right now!

### Test on Android Phone
1. Enable USB Debugging on phone
2. Connect with USB cable
3. `flutter run`
✅ You can do this with your Android phone!

### Test on iOS Simulator
❌ Need Mac

### Test on iOS Phone
❌ Need Mac + Apple Developer Account

### Test on Web
```bash
flutter run -d chrome
```
✅ You can do this now!

### Test on Windows
```bash
flutter run -d windows
```
✅ You can do this now!

---

## 🎯 What You Should Do Next

1. **Get Firebase Credentials** (URGENT)
   - Read: `FIREBASE_SETUP_QUICK_GUIDE.md`
   - Download: `google-services.json`
   - Update: `lib/firebase_options.dart`

2. **Test on Android** (Immediate)
   ```bash
   flutter run -d emulator-5554
   ```

3. **Build Shareable APK** (Optional)
   ```bash
   flutter build apk --release
   ```

4. **iOS Later** (When you have Mac)
   - Repeat setup for iOS platform
   - Both platforms will share same code ✅

---

**Status**: Ready to run on Android! 🚀

Next: Update Firebase config, then run the app! 🎓
