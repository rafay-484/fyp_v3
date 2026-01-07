# Urdu & Punjabi Tutor 📚

ایک جدید Flutter ایپلیکیشن جو اردو اور پنجابی زبانیں سیکھنے میں مدد کرتی ہے۔

## خصوصیات ✨

### 1. **AI-طاقت والی تعلیم**
- XLM-RoBERTa ماڈل استعمال کرتے ہوئے
- ذاتی نوعیت کی سیکھ کا تجربہ
- خودکار قواعد کی تصحیح

### 2. **آواز پر مبنی سیکھ**
- Speech-to-Text تکنیک
- Text-to-Speech خصوصیات
- لہجہ اور تلفظ کی تشریح

### 3. **گیمیفیکیشن نظام**
- پوائنٹس اور سطحوں کا نظام
- بیج کی حصول
- روزانہ سٹریک ٹریکنگ
- حقیقی وقت میں تاثیر

### 4. **باب پر مبنی سیکھ**
- منظم باب اور اسباق
- ترقی کی ٹریکنگ
- مقفل/کھلے باب کا نظام

### 5. **قواعد الفاظ کی تصحیح**
- AI سے چلنے والی تصحیح
- الفاظ کی بہتریاں
- تفصیلی تاثیر

### 6. **ذہین معاون**
- حقیقی وقت میں جوابات
- عام جملے کی لائبریری
- دونوں زبانوں میں سپورٹ

### 7. **بہو لسانی سپورٹ**
- اردو اور پنجابی دونوں
- انگریزی انٹرفیس کے ساتھ
- ثقافتی مواد

### 8. **صارف کی پروفائل**
- ترقی کی تاریخ
- شماریات اور تجزیات
- بیج کی نمائش

## رنگ کی ترتیب 🎨

- **بنیادی سبز**: `#4CAF50`
- **ہلکا سبز**: `#81C784`
- **سفید**: `#FFFFFF`
- **ہلکا خاکستری**: `#F5F5F5`

## تکنیکی ڈھانچہ 🏗️

### Frontend (Flutter/Dart)
- Flutter 3.9+
- Provider for state management
- Material Design 3

### Backend Integration (آنے والا)
- Firebase Authentication
- Cloud Firestore
- Firebase Storage

### AI Services (آنے والا)
- XLM-RoBERTa Model
- Speech Recognition
- Text-to-Speech

## منصوبہ ڈائریکٹری

```
lib/
├── main.dart                    # مرکزی اینٹری پوائنٹ
├── themes/
│   └── app_theme.dart          # تھیم اور رنگوں کی ترتیب
├── providers/
│   ├── user_provider.dart       # صارف کی حالت
│   ├── learning_provider.dart   # سیکھنے کی حالت
│   └── gamification_provider.dart # گیمیفیکیشن
├── screens/
│   ├── splash_screen.dart       # سپلیش اسکرین
│   ├── home_screen.dart         # ہوم اسکرین
│   ├── auth/
│   │   ├── login_screen.dart    # لاگ ان
│   │   └── signup_screen.dart   # رجسٹر
│   ├── learning/
│   │   ├── learn_screen.dart    # تعلیم کی اسکرین
│   │   ├── lesson_screen.dart   # سبق
│   │   └── quiz_screen.dart     # کوئز
│   ├── grammar/
│   │   └── grammar_checker_screen.dart # قواعد الفاظ
│   ├── voice/
│   │   └── voice_assistant_screen.dart # آواز معاون
│   └── profile/
│       └── profile_screen.dart  # پروفائل
└── services/
    ├── ai_service.dart          # AI انضمام
    ├── speech_service.dart      # آواز سروسز
    └── firebase_service.dart    # Firebase انضمام
```

## ڈیپنڈنسیز 📦

### مرکزی ڈیپنڈنسیز
- `flutter`: Flutter Framework
- `provider`: State Management
- `firebase_core`: Firebase Core
- `firebase_auth`: Authentication
- `cloud_firestore`: Database
- `firebase_storage`: Storage

### آواز اور بولی
- `speech_to_text`: Speech Recognition
- `flutter_tts`: Text-to-Speech

### Utilities
- `shared_preferences`: Local Storage
- `http`: API Calls
- `intl`: Localization
- `uuid`: Unique IDs

## حالیہ ترقی 🚀

- ✅ بنیادی UI ڈھانچہ
- ✅ صارف کی ترتیب (Authentication UI)
- ✅ تعلیم کی نظام
- ✅ گیمیفیکیشن انضمام
- ✅ آواز معاون UI
- ✅ قواعد الفاظ کی تصحیح UI
- ⏳ Firebase انضمام (آنے والا)
- ⏳ AI Model انضمام (آنے والا)
- ⏳ Speech Recognition انضمام (آنے والا)

## شروع کریں 🎯

1. **منحصرات انسٹال کریں**
   ```bash
   flutter pub get
   ```

2. **ایپ چلائیں**
   ```bash
   flutter run
   ```

3. **دستاویزات**
   - Flutter: https://flutter.dev
   - Provider: https://pub.dev/packages/provider
   - Firebase: https://firebase.google.com

## مستقبل کی خصوصیات 🔮

- [ ] Offline Mode
- [ ] Social Features
- [ ] Leaderboard
- [ ] Advanced Analytics
- [ ] Certification System
- [ ] Community Forum

## لائسنس 📄

MIT License

---

**تیار شدہ**: October 2025
**ورژن**: 1.0.0
**حالت**: Development 🔨
