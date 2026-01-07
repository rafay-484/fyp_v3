# اردو اور پنجابی ٹیوٹر - ترقی کی ہدایات

## نظرِثانی

یہ ایک جدید Flutter ایپلیکیشن ہے جو اردو اور پنجابی زبانیں سیکھنے میں معاونت کرتی ہے۔

## تیار شدہ خصوصیات

### ✅ مکمل شدہ

1. **تھیم اور UI**
   - روشن سبز اور سفید رنگ کی ترتیب
   - Material Design 3
   - تمام اسکرین میں مطابقت پذیری

2. **صارف کی ترتیب**
   - لاگ ان اسکرین
   - رجسٹر اسکرین
   - پروفائل ڈیشبورڈ

3. **تعلیم کا نظام**
   - باب اور اسباق
   - لیسن ڈسپلے
   - الفاظ کی تشریح

4. **کوئز نظام**
   - متعدد اختیاری سوالات
   - فوری تاثیر
   - پوائنٹ سسٹم

5. **گیمیفیکیشن**
   - پوائنٹس اور سطحیں
   - بیج کی حصول
   - سٹریک ٹریکنگ

6. **قواعد الفاظ کی تصحیح**
   - متن کی تصحیح انٹرفیس
   - تفصیلی تاثیر
   - مفید نکات

7. **آواز معاون**
   - عام جملے
   - Speech UI
   - جواب کی تشریح

## ابھی باقی خصوصیات

### ⏳ آنے والی

1. **Firebase انضمام**
   - صارف کی توثیق
   - ڈیٹابیس سٹوریج
   - ڈیٹا کی سنکروناائزیشن

2. **AI انضمام**
   - XLM-RoBERTa ماڈل
   - AI قواعد الفاظ کی تصحیح
   - ذاتی نوعیت کے سوالات

3. **بولی کی سہولیات**
   - Speech-to-Text
   - Text-to-Speech
   - تلفظ کی تشریح

## فائل ڈھانچہ

```
lib/
├── main.dart                          # بنیادی اپلیکیشن
├── themes/app_theme.dart              # رنگوں اور تھیم کی ترتیب
├── providers/
│   ├── user_provider.dart             # صارف کی حالت
│   ├── learning_provider.dart         # سیکھنے کی حالت
│   └── gamification_provider.dart     # گیمیفیکیشن کی حالت
├── screens/
│   ├── splash_screen.dart             # شروع کریں
│   ├── home_screen.dart               # گھر کا صفحہ
│   ├── auth/
│   │   ├── login_screen.dart          # داخل ہوں
│   │   └── signup_screen.dart         # رجسٹر کریں
│   ├── learning/
│   │   ├── learn_screen.dart          # تعلیم شروع
│   │   ├── lesson_screen.dart         # سبق دیکھیں
│   │   └── quiz_screen.dart           # کوئز میں حصہ
│   ├── grammar/
│   │   └── grammar_checker_screen.dart # قواعد تصحیح
│   ├── voice/
│   │   └── voice_assistant_screen.dart # آواز معاون
│   └── profile/
│       └── profile_screen.dart        # پروفائل دیکھیں
└── services/
    ├── ai_service.dart                # AI خدمات
    ├── speech_service.dart            # بولی کی خدمات
    └── firebase_service.dart          # Firebase خدمات
```

## چلانے کی ہدایات

### 1. منحصرات انسٹال کریں

```bash
cd c:\Users\Dell\projects\fyp_v1
flutter pub get
```

### 2. ایپ چلائیں

**Android میں:**
```bash
flutter run
```

**iOS میں:**
```bash
flutter run -d ios
```

**ویب میں:**
```bash
flutter run -d chrome
```

### 3. بلڈ کریں

**Android APK:**
```bash
flutter build apk
```

**iOS IPA:**
```bash
flutter build ios
```

## اہم اسکرینیں

### 1. Splash Screen
- خوش آمدید انیمیشن
- 3 سیکنڈ میں خود بند ہو جاتا ہے

### 2. Login Screen
- ای میل اور پاس ورڈ کے ساتھ
- رجسٹر لنک
- خوشگوار ڈیزائن

### 3. Home Screen
- 4 ٹیبیں (تعلیم، قواعد، آواز، پروفائل)
- زندہ پوائنٹ ڈسپلے
- Navigation Bar

### 4. Learn Screen
- اردو/پنجابی ٹیبز
- باب کی فہرست
- ترقی کی پٹی

### 5. Lesson Screen
- سبق کے صفحات
- الفاظ کی فہرست
- آواز بٹن

### 6. Quiz Screen
- متعدد اختیاری
- فوری تاثیر
- حتمی اسکور

### 7. Grammar Screen
- متن کی تصحیح
- تفصیلی تجاویز
- نکات

### 8. Voice Screen
- عام جملے
- آواز ریکارڈنگ
- جواب دی

### 9. Profile Screen
- صارف کی معلومات
- اعدادوشمار
- بیج کی نمائش

## رنگوں کی تفریق

```dart
primaryGreen = #4CAF50      // بنیادی سبز
lightGreen = #81C784        // ہلکا سبز
darkGreen = #388E3C         // گہرا سبز
accentGreen = #A5D6A7       // لہجہ سبز
white = #FFFFFF             // سفید
lightGray = #F5F5F5         // ہلکا خاکستری
darkGray = #424242          // گہرا خاکستری
```

## ڈیٹا ماڈلز

### User Model
```dart
class User {
  String id;
  String email;
  String name;
  String selectedLanguage;
  int points;
  int level;
  List<String> unlockedBadges;
  DateTime createdAt;
}
```

### Chapter Model
```dart
class Chapter {
  String id;
  String title;
  String language;
  int lessonCount;
  bool isLocked;
  double progress;
}
```

### Lesson Model
```dart
class Lesson {
  String id;
  String chapterId;
  String title;
  String content;
  List<String> vocabularyWords;
  String? audioUrl;
  bool isCompleted;
}
```

### Badge Model
```dart
class Badge {
  String id;
  String name;
  String description;
  String icon;
  DateTime unlockedAt;
}
```

## State Management (Provider)

### UserProvider
- موجودہ صارف
- لاگ ان حالت
- زبان کی ترتیب

### LearningProvider
- باب
- اسباق
- کوئز
- ترقی

### GamificationProvider
- پوائنٹس
- سطحیں
- بیج
- سٹریک

## آگے بڑھنے کے مراحل

### Phase 2: Firebase انضمام
1. Firebase پروجیکٹ بنائیں
2. Authentication شامل کریں
3. Firestore ڈیٹابیس سیٹ کریں
4. Cloud Storage کنفیگ کریں

### Phase 3: AI انضمام
1. XLM-RoBERTa API سیٹ کریں
2. قواعد الفاظ کی سروس
3. ذاتی نوعیت کے سوالات

### Phase 4: بولی کی سہولیات
1. Speech Recognition
2. Text-to-Speech
3. آواز کی تشریح

### Phase 5: تیسری طرف کی خدمات
1. Analytics
2. Crash Reporting
3. Push Notifications

## مسائل کا حل

### ڈیپنڈنسی مسائل
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### بلڈ مسائل
```bash
flutter clean
flutter build apk --release
```

### رن ٹائم مسائل
```bash
flutter doctor
flutter doctor --android-licenses
```

## مفید لنکس

- [Flutter ڈاکومنٹیشن](https://flutter.dev)
- [Provider Package](https://pub.dev/packages/provider)
- [Firebase Flutter](https://firebase.google.com/docs/flutter/setup)
- [Material Design](https://material.io/design)

---

**تیار شدہ**: اکتوبر 2025
**ورژن**: 1.0.0
**حالت**: ترقی میں 🔨
