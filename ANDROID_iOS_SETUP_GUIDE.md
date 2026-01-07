# 🚀 Running Your App on Android & iOS

## 📦 What is Package Name?

**Package Name** (also called **Application ID** or **Bundle Identifier**) is a unique identifier for your app on app stores.

### Your Current Package Name

**Android Package Name**: `com.example.fyp_v1`
**Location**: `android/app/build.gradle.kts` line 9

```gradle
applicationId = "com.example.fyp_v1"
```

---

## 🎯 Package Name Explained

### Format: `com.company.appname`

| Part | Meaning | Example |
|------|---------|---------|
| `com` | Internet domain suffix (always "com") | `com` |
| `example` | Company/developer name (reverse domain) | `example` |
| `fyp_v1` | Application name | `fyp_v1` |

### Your Breakdown
```
com.example.fyp_v1
├─ com       = Internet domain
├─ example   = Your company (currently placeholder)
└─ fyp_v1    = Your app name
```

### Real Examples
| App | Package Name |
|-----|--------------|
| Gmail | `com.google.android.gm` |
| WhatsApp | `com.whatsapp` |
| Instagram | `com.instagram.android` |
| Your App | `com.example.fyp_v1` |

---

## ⚙️ Changing Package Name (Optional)

If you want to change from `com.example.fyp_v1` to something professional:

### Step 1: Update Android

**File**: `android/app/build.gradle.kts`

```gradle
// BEFORE
applicationId = "com.example.fyp_v1"

// AFTER (Example)
applicationId = "com.rafay.fyp_v1"  // or com.yourcompany.fyptutor
```

### Step 2: Update iOS

**File**: `ios/Runner.pbxproj`

Search for `PRODUCT_BUNDLE_IDENTIFIER` and update similarly.

### Step 3: Rebuild

```bash
flutter clean
flutter pub get
flutter run
```

---

## 📱 Running on Android

### Option 1: Android Emulator (Easiest)

#### Check Available Emulators
```bash
flutter emulators
```

#### List Currently Running
```bash
flutter devices
```

You currently have: **`emulator-5554`** (Android 16, x86_64)

#### Run on Android Emulator
```bash
cd c:\Users\Dell\projects\fyp_v1
flutter run -d emulator-5554
```

### Option 2: Physical Android Device

#### Prerequisites
1. **USB Cable**: Connect Android phone to PC
2. **USB Debugging**: Enable on phone
   - Settings → Developer Options → USB Debugging → ON
3. **Drivers**: Install Android USB drivers

#### Run on Physical Device
```bash
# List connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

---

## 🍎 Running on iOS

### ⚠️ Important: Mac Required!

**iOS development requires:**
- ✅ macOS (only available on Mac)
- ❌ Windows (cannot develop for iOS)
- ❌ Linux (cannot develop for iOS)

### Since You're on Windows...

You have **two options**:

#### Option 1: Remote Mac Build (Enterprise)
- Rent Mac in cloud (expensive)
- Use build farm service (EAS Build, CodeMagic)
- Not recommended for learning

#### Option 2: Android First, iOS Later
- Develop on Android now (you can do this)
- Request team member with Mac to build iOS
- Or wait until you have access to Mac

### If You Get a Mac Later...

Once on macOS, iOS setup is:
```bash
# Setup iOS dependencies
flutter pub get

# Run on iOS simulator
open -a Simulator
flutter run

# Or specific device
flutter run -d "iPhone 15"
```

---

## 🎬 Running Your App NOW (Android)

### Step 1: Ensure Android Emulator is Running

```bash
# Check if emulator is running
flutter devices
```

**Expected output**:
```
Found 4 connected devices:
  emulator-5554 (mobile)
```

If not showing, start it:
```bash
flutter emulators --launch emulator-5554
```

### Step 2: Build and Run

```bash
cd c:\Users\Dell\projects\fyp_v1
flutter clean
flutter pub get
flutter run -d emulator-5554
```

### Step 3: Wait for App to Load

- **First run**: Takes 2-3 minutes (building APK)
- **Later runs**: Takes 30-60 seconds (hot reload)

### Step 4: See Your App!

You should see:
1. Splash screen (3 seconds)
2. Login/Signup interface (bilingual)
3. Your app UI

---

## 🔄 Hot Reload & Hot Restart

### Hot Reload (Fast - 1 second)
```bash
# In terminal where app is running, press:
r

# Or type:
flutter hot reload
```
**What it does**: Refreshes UI without losing state (fast)

### Hot Restart (Medium - 5 seconds)
```bash
# In terminal where app is running, press:
R

# Or type:
flutter hot restart
```
**What it does**: Restarts app but keeps emulator running (medium speed)

### Full Rebuild (Slow - 2-3 minutes)
```bash
# In terminal, press Ctrl+C to stop
# Then:
flutter clean
flutter run -d emulator-5554
```
**What it does**: Rebuilds from scratch (slowest but most thorough)

---

## 📊 Your Device Status

### Current Setup
```
✅ Android Emulator: emulator-5554 (Android 16)
✅ Android SDK: Ready
✅ Flutter: 3.35.2
❌ iOS Simulator: Not available (Windows only)
❌ Physical iOS: Not available (Mac only)
```

### What You Can Do NOW
- ✅ Run on Android Emulator
- ✅ Run on Android Phone (with USB + developer mode)
- ❌ Run on iOS (need Mac)

---

## 🚀 Quick Commands

### Run on Android Emulator
```bash
flutter run -d emulator-5554
```

### Run on Specific Device
```bash
flutter run -d <device-id>
```

### Run in Release Mode (Optimized)
```bash
flutter run --release -d emulator-5554
```

### Stop Running App
```bash
# Press in terminal:
q

# Or Ctrl+C
```

### Build Only (Don't Run)
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

### List All Devices
```bash
flutter devices
```

---

## 📦 APK File Location

After building, your APK is at:
```
build/app/outputs/flutter-apk/app-debug.apk
```

**Size**: ~150 MB (debug build)
**Size**: ~50 MB (release build)

### Share APK for Testing
You can share `app-debug.apk` or `app-release.apk` with others to install on their phones.

---

## 🔧 Firebase + Android/iOS

### For Firebase to Work:

**Android** ✅ (You're setup already):
- `android/app/google-services.json` (download from Firebase)
- Package name: `com.example.fyp_v1`

**iOS** (When you get a Mac):
- `ios/Runner/GoogleService-Info.plist` (download from Firebase)
- Bundle ID: `com.example.fyp_v1` (must match Android)

### Get iOS Firebase Config

When ready for iOS:
1. Firebase Console → Your Project → Add App → iOS
2. Bundle ID: `com.example.fyp_v1`
3. Download `GoogleService-Info.plist`
4. Add to Xcode project (requires Mac)

---

## 📱 Testing Scenarios

### Scenario 1: Quick UI Test
```bash
flutter run -d emulator-5554
# Make changes in code
# Press 'r' for hot reload
```

### Scenario 2: Full Test
```bash
flutter run -d emulator-5554
# Use app normally
# Test all features
# Press 'q' to stop
```

### Scenario 3: Performance Test
```bash
flutter run --release -d emulator-5554
# App runs in optimized mode
# Closest to what users experience
```

### Scenario 4: Create Shareable APK
```bash
flutter build apk --release
# Share: build/app/outputs/flutter-apk/app-release.apk
# File size: ~50 MB
```

---

## 🎯 Step-by-Step: Run App Now

1. **Open Terminal**:
   ```bash
   cd c:\Users\Dell\projects\fyp_v1
   ```

2. **Start Emulator** (if not running):
   ```bash
   flutter emulators --launch emulator-5554
   ```

3. **Build & Run**:
   ```bash
   flutter run -d emulator-5554
   ```

4. **Wait** (2-3 minutes on first run)

5. **See Your App** in emulator!

---

## ❓ FAQ

**Q: Can I run on multiple devices at once?**
A: Yes! Open multiple terminals and run each with a different device ID.

**Q: Why does Android build take so long?**
A: First build compiles everything. Later runs are faster with hot reload.

**Q: What's the difference between debug and release APK?**
A: Debug is bigger, has debugging info. Release is smaller, optimized.

**Q: Can I test on my actual phone?**
A: Yes! Enable USB Debugging, connect via USB cable, run `flutter run`.

**Q: My app crashes on the emulator?**
A: Check console for error messages. Usually missing dependencies or Firebase config issue.

**Q: How do I stop the app?**
A: Press 'q' in the terminal where it's running, or Ctrl+C.

---

## 🎓 Summary

| Feature | Android | iOS | Windows |
|---------|---------|-----|---------|
| Emulator | ✅ Available | ❌ Mac only | ✅ Available |
| Package Name | `com.example.fyp_v1` | `com.example.fyp_v1` | N/A |
| Run Now | ✅ YES | ❌ Need Mac | ✅ YES |
| Firebase Config | `google-services.json` | `GoogleService-Info.plist` | N/A |
| Status | 🟢 Ready | 🔴 Mac needed | 🟢 Ready |

---

**Your app is ready to run on Android now!** 🚀

Use: `flutter run -d emulator-5554`

For iOS, you'll need a Mac or use cloud build services like EAS Build.
