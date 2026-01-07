# 🎓 اردو اور پنجابی ٹیوٹر - مکمل اطلاع

## 📱 ایپ کا مقصد

یہ Flutter میں بنی ہوئی ایک تعلیمی ایپ ہے جو صارفین کو اردو اور پنجابی زبانیں سیکھنے میں مدد دیتی ہے۔ ایپ AI، آواز کی سہولیات، اور گیمیفیکیشن استعمال کرتے ہوئے سیکھنے کے تجربے کو بہتر بناتی ہے۔

## ✨ اہم خصوصیات

### 1️⃣ **تعلیم کا نظام**
- ✅ اردو اور پنجابی دونوں میں
- ✅ منظم باب اور اسباق
- ✅ الفاظ کی تشریح
- ✅ ترقی کی ٹریکنگ
- ✅ متعدد اختیاری کوئز

### 2️⃣ **آواز کی سہولیات** (آنے والی)
- ⏳ Speech Recognition
- ⏳ Text-to-Speech
- ⏳ لہجہ کی تشریح

### 3️⃣ **AI اور قواعس**
- ✅ قواعس الفاظ کی تصحیح UI
- ⏳ XLM-RoBERTa انضمام
- ⏳ الفاظ کی تجاویز

### 4️⃣ **گیمیفیکیشن** 
- ✅ پوائنٹس سسٹم
- ✅ سطحیں
- ✅ بیج
- ✅ روزانہ سٹریک

### 5️⃣ **صارف کا انتظام**
- ✅ لاگ ان اور رجسٹر
- ✅ پروفائل ڈیشبورڈ
- ✅ شماریات

## 📂 پروجیکٹ کی ساخت

```
fyp_v1/
├── lib/
│   ├── main.dart                         # بنیاد
│   ├── themes/
│   │   └── app_theme.dart               # رنگین ڈیزائن
│   ├── providers/                        # State Management
│   │   ├── user_provider.dart
│   │   ├── learning_provider.dart
│   │   └── gamification_provider.dart
│   ├── screens/                          # تمام صفحات
│   │   ├── splash_screen.dart
│   │   ├── home_screen.dart
│   │   ├── auth/
│   │   ├── learning/
│   │   ├── grammar/
│   │   ├── voice/
│   │   └── profile/
│   └── services/                         # APIs اور سروسز
│       ├── ai_service.dart
│       ├── speech_service.dart
│       └── firebase_service.dart
├── pubspec.yaml                          # منحصرات
├── FEATURES.md                           # خصوصیات کی فہرست
├── DEVELOPMENT_GUIDE.md                  # ترقی کی ہدایات
├── API_INTEGRATION_GUIDE.md              # API رہنمائی
└── README.md                             # اہم معلومات
```

## 🎨 رنگوں کی ترتیب

| رنگ | ہیکس | استعمال |
|-----|-----|--------|
| بنیادی سبز | #4CAF50 | بٹن، ہیڈر |
| ہلکا سبز | #81C784 | فارم، کارڈز |
| سفید | #FFFFFF | پس منظر |
| ہلکا خاکستری | #F5F5F5 | صفحے کی پس منظر |

## 🛠️ استعمال کی گئی تکنیکیں

### Framework اور Languages
- **Flutter 3.35+** - UI ڈیولپمنٹ
- **Dart 3.9+** - پروگرامنگ لینگویج

### State Management
- **Provider 6.0.0** - حالت کی تبدیلی

### Backend (آنے والی)
- **Firebase Authentication** - صارف کی توثیق
- **Cloud Firestore** - ڈیٹابیس
- **Firebase Storage** - فائلیں

### AI اور NLP
- **XLM-RoBERTa** - زبان کی پروسیسنگ
- **Flask** - Backend سرور

### آواز
- **speech_to_text** - بولی کو متن میں
- **flutter_tts** - متن کو بولی میں

### دیگر
- **Intl** - ترجمہ
- **SharedPreferences** - مقامی ڈیٹا
- **HTTP** - API کالز

## 📊 ڈیٹا ماڈلز

### User
```dart
{
  id: String,
  email: String,
  name: String,
  selectedLanguage: 'urdu' | 'punjabi',
  points: int,
  level: int,
  unlockedBadges: List<String>,
  createdAt: DateTime
}
```

### Chapter
```dart
{
  id: String,
  title: String,
  language: 'urdu' | 'punjabi',
  lessonCount: int,
  isLocked: bool,
  progress: double (0-100)
}
```

### Badge
```dart
{
  id: String,
  name: String,
  description: String,
  icon: String (emoji),
  unlockedAt: DateTime
}
```

## 🚀 شروع کرنے کی ہدایات

### 1. منحصرات انسٹال کریں
```bash
cd c:\Users\Dell\projects\fyp_v1
flutter pub get
```

### 2. ایپ چلائیں
```bash
flutter run
```

### 3. Android پر
```bash
flutter run -d <device-id>
```

### 4. Release Build
```bash
flutter build apk --release
```

## 📝 صفحات کی تفریح

| صفحہ | ڈیسکپشن | حالت |
|------|---------|------|
| Splash | خوش آمدید | ✅ مکمل |
| Login | لاگ ان | ✅ مکمل |
| Signup | رجسٹر | ✅ مکمل |
| Home | بنیادی صفحہ | ✅ مکمل |
| Learn | تعلیم شروع | ✅ مکمل |
| Lesson | سبق | ✅ مکمل |
| Quiz | کوئز | ✅ مکمل |
| Grammar | قواعس | ✅ مکمل |
| Voice | آواز | ✅ مکمل |
| Profile | پروفائل | ✅ مکمل |

## 📈 ترقی کا منصوبہ

### Phase 1 ✅ (مکمل)
- UI/UX ڈیزائن
- بنیادی خصوصیات
- State Management
- Navigation

### Phase 2 ⏳ (آنے والا)
- Firebase Setup
- Authentication
- Database
- Cloud Sync

### Phase 3 ⏳ (آنے والا)
- AI Model Integration
- Grammar Checking
- Quiz Generation
- Personalization

### Phase 4 ⏳ (آنے والا)
- Speech Recognition
- Text-to-Speech
- Voice Features
- Pronunciation

### Phase 5 ⏳ (آنے والا)
- Analytics
- Push Notifications
- Social Features
- Leaderboard

## 🔗ملتے جلتے لنکس

- 📚 [Flutter Docs](https://flutter.dev)
- 🔥 [Firebase](https://firebase.google.com)
- 🤖 [Hugging Face Models](https://huggingface.co)
- 📖 [Material Design](https://material.io)

## 🐛 عام مسائل

### مسئلہ: Dependencies ڈاؤن لوڈ نہیں ہو رہے
**حل:**
```bash
flutter clean
flutter pub get
```

### مسئلہ: Firebase Error
**حل:**
```bash
flutterfire configure
```

### مسئلہ: Device نہیں مل رہا
**حل:**
```bash
flutter devices
adb devices
```

## 👥 ٹیم

**Developed by:** FYP Student
**Duration:** October 2025
**Advisor:** [Faculty Name]

## 📞 رابطے کی معلومات

- 📧 Email: project@example.com
- 🐙 GitHub: [repository-link]
- 📱 Support: [contact-info]

## 📜 لائسنس

MIT License - آزادانہ استعمال

---

## 🎯 اگلے مراحل

1. **Firebase Project بنائیں**
   - Google Cloud Console میں
   - Authentication شامل کریں
   - Firestore سیٹ کریں

2. **Backend API سیٹ کریں**
   - Flask Server
   - XLM-RoBERTa Model
   - API Endpoints

3. **Testing شروع کریں**
   - Unit Tests
   - Widget Tests
   - Integration Tests

4. **Deployment تیار کریں**
   - Google Play Store
   - Apple App Store
   - Web Deployment

---

**ستمبر 2025 - اکتوبر 2025** | **ورژن 1.0.0** | **حالت: ترقی میں 🔨**

**تمام خصوصیات کے ساتھ اردو اور پنجابی سیکھنے کے لیے ایک جدید حل!**

---

### 🎉 مبارک ہو!

آپ کا ایپ اب تیار ہے۔ اگلے مراحل میں Firebase اور AI انضمام شامل کریں۔

**Happy Coding! 💻✨**
