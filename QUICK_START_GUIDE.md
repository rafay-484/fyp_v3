# Quick Reference Guide - Bilingual Interface, Firebase & XLM-RoBERTa

## 🌐 For English Speakers

All UI elements now display both English and the original Urdu/Punjabi text:

| Screen | English Label | Urdu | Punjabi |
|--------|--------------|------|---------|
| Login | `Login` | داخل ہوں | ਲਾਗ ਇਨ |
| Sign Up | `Sign Up` | نیا اکاؤنٹ بنائیں | ਸਾਈਨ ਅਪ |
| Learn | `Learn` | سیکھیں | ਸਿੱਖੋ |
| Quiz | `Quiz` | ٹیسٹ | ਕਵਿਜ਼ |
| Grammar | `Grammar Checker` | گرامر چیکر | ਸ਼ੈਲੀ ਜਾਂਚਕਾਰ |

---

## 🔐 Firebase Authentication Usage

### For Login (lib/screens/auth/login_screen.dart)
```dart
// Authenticate user
final userId = await FirebaseService.signIn(email, password);

// Retrieve user progress
final progress = await FirebaseService.getProgress(userId);

// Access user data
print(progress['totalPoints']);  // User's earned points
print(progress['currentLevel']); // User's learning level
print(progress['accuracy']);     // Quiz accuracy %
```

### For Sign Up (lib/screens/auth/signup_screen.dart)
```dart
// Create new user
final userId = await FirebaseService.signUp(email, password);

// User automatically gets:
{
  'email': 'user@example.com',
  'createdAt': DateTime.now(),
  'selectedLanguage': 'urdu',  // User can change this
  'totalPoints': 0,
  'currentLevel': 1,
  'lessonsCompleted': 0,
  'quizzesAttempted': 0,
  'accuracy': 0.0,
}
```

### Save Learning Progress
```dart
await FirebaseService.saveProgress(userId, {
  'totalPoints': 250,
  'currentLevel': 3,
  'lessonsCompleted': 5,
  'quizzesAttempted': 8,
  'accuracy': 82.5,
});
```

---

## 🤖 XLM-RoBERTa AI Features

### 1. Grammar Checking

**For Grammar Checker Screen**:
```dart
final result = await AIService.checkGrammar(userText, 'urdu');

// Returns:
{
  'isCorrect': true/false,
  'errors': ['List of grammar errors'],
  'suggestions': ['List of corrections'],
  'confidence': 0.95  // Confidence score (0-1)
}

// Display to user:
if (result['isCorrect']) {
  showMessage('✓ No grammar errors found!');
} else {
  showMessage('✗ Found errors: ${result['errors'].join(", ")}');
  showSuggestions(result['suggestions']);
}
```

**Supported Languages**: `'urdu'` or `'punjabi'`

### 2. AI-Generated Quiz Questions

**For Quiz Screen**:
```dart
final questions = await AIService.generateQuestions(
  'urdu',           // language: 'urdu' or 'punjabi'
  'greetings',      // topic
  5,                // number of questions
);

// Each question format:
{
  'question': 'Spell the word: "کتاب" (Book)',
  'options': ['K-T-B', 'K-I-T-B', 'KT-AB', 'K-I-T-A-B'],
  'answer': 'K-I-T-A-B',
  'explanation': 'The word is spelled K-I-T-A-B',
}
```

### 3. Vocabulary Suggestions

**For Learning Content**:
```dart
final vocabulary = await AIService.suggestVocabulary(userText, 'urdu');

// Returns common phrases:
{
  'سلام': 'Assalamu Alaikum (Peace be upon you)',
  'شکریہ': 'Thank you',
  'براہ کرم': 'Please',
  'کیا حال ہے': 'How are you?',
  'اردو': 'Urdu (language)',
}

// Display to user
vocabulary.forEach((word, meaning) {
  showVocabularyCard(word: word, translation: meaning);
});
```

### 4. Sentiment Analysis

**For Text Analysis**:
```dart
final sentiment = await AIService.analyzeSentiment(userText, 'urdu');

// Returns:
{
  'sentiment': 'positive',        // or 'negative' or 'neutral'
  'confidence': 0.85,
  'label': 'The text sentiment is positive',
}

// Use for feedback
if (sentiment['sentiment'] == 'positive') {
  showEncouragement('Great! You\'re using positive language! 🎉');
}
```

---

## 📚 Using AppStrings for Multilingual Content

### In Any Widget:
```dart
import '../../localization/app_strings.dart';

// Use strings consistently
Text(AppStrings.login)              // "Login"
Text(AppStrings.urdu)               // "Urdu (اردو)"
Text(AppStrings.checkGrammar)       // "Check Grammar (گرامر چیک کریں)"
Text(AppStrings.learnUrduPunjabi)   // "Learn Urdu & Punjabi..."
```

### Common Strings Available:
```dart
AppStrings.appTitle           // "Urdu & Punjabi Tutor"
AppStrings.login              // "Login"
AppStrings.signup             // "Sign Up"
AppStrings.email              // "Email"
AppStrings.password           // "Password"
AppStrings.urdu               // "Urdu (اردو)"
AppStrings.punjabi            // "Punjabi (پنجابی)"
AppStrings.englissh           // "English (انگریزی)"
AppStrings.grammarCheckTitle  // "Grammar Checker"
AppStrings.voiceAssistant     // "Voice Assistant"
AppStrings.profile            // "Profile (پروفائل)"
AppStrings.logout             // "Logout (لاگ آؤٹ)"
AppStrings.loading            // "Loading (لوڈ ہو رہا ہے)"
AppStrings.error              // "Error (غلطی)"
AppStrings.success            // "Success (کامیاب)"
```

---

## 🔧 Integration Examples

### Example 1: Login Screen Integration
```dart
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  void _login() async {
    try {
      final userId = await FirebaseService.signIn(
        emailController.text,
        passwordController.text,
      );
      
      if (userId != null) {
        final progress = await FirebaseService.getProgress(userId);
        
        // Show success with AppStrings
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.loginSuccess))
        );
        
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.loginFailed))
      );
    }
  }
}
```

### Example 2: Grammar Checker Screen Integration
```dart
class GrammarCheckerScreen extends StatefulWidget {
  @override
  State<GrammarCheckerScreen> createState() => _GrammarCheckerScreenState();
}

class _GrammarCheckerScreenState extends State<GrammarCheckerScreen> {
  void _checkGrammar() async {
    final result = await AIService.checkGrammar(
      textController.text,
      selectedLanguage, // 'urdu' or 'punjabi'
    );
    
    setState(() {
      grammarResult = result;
    });
    
    // Display result
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(result['isCorrect'] 
          ? AppStrings.success 
          : AppStrings.errorsFound),
        content: Text(result['errors'].join('\n')),
      ),
    );
  }
}
```

### Example 3: Quiz Generation Integration
```dart
class QuizScreen extends StatefulWidget {
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  void _loadQuestions() async {
    final questions = await AIService.generateQuestions(
      selectedLanguage,  // 'urdu' or 'punjabi'
      'all',
      10, // 10 questions per quiz
    );
    
    setState(() {
      quizQuestions = questions;
      isLoading = false;
    });
  }
  
  void _checkAnswer(String selected) {
    final question = quizQuestions[currentIndex];
    final isCorrect = selected == question['answer'];
    
    setState(() {
      score += isCorrect ? 10 : 0;
      showResult = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect 
          ? AppStrings.correct 
          : AppStrings.incorrect),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
      ),
    );
  }
}
```

---

## 📊 Firebase Firestore Schema

All user data is stored in Firestore with this structure:

```
Collection: users
├─ Document: {userId}
│  ├─ email: "user@example.com"
│  ├─ createdAt: Timestamp
│  ├─ selectedLanguage: "urdu"
│  ├─ totalPoints: 250
│  ├─ currentLevel: 3
│  ├─ lessonsCompleted: 5
│  ├─ quizzesAttempted: 8
│  ├─ accuracy: 82.5
│  └─ lastUpdated: Timestamp
```

**To Query User Data in App**:
```dart
final userId = FirebaseAuth.instance.currentUser!.uid;
final doc = await FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .get();

final userData = doc.data();
print('Points: ${userData['totalPoints']}');
print('Level: ${userData['currentLevel']}');
print('Accuracy: ${userData['accuracy']}%');
```

---

## 🚀 Deployment Checklist

### Before Publishing

- [ ] **Firebase Setup**
  - [ ] Create Firebase project
  - [ ] Enable Email/Password auth
  - [ ] Configure Firestore rules
  - [ ] Add Android SHA-1 fingerprint

- [ ] **XLM-RoBERTa Setup**
  - [ ] Get Hugging Face API token
  - [ ] Update API endpoint in `ai_service.dart`
  - [ ] Test grammar checking with sample text
  - [ ] Verify quiz generation

- [ ] **Testing**
  - [ ] Test login/signup
  - [ ] Test progress save/load
  - [ ] Test grammar checker
  - [ ] Test offline mode
  - [ ] Test on multiple devices

- [ ] **Security**
  - [ ] Enable Firebase Security Rules
  - [ ] Add rate limiting
  - [ ] Secure API tokens
  - [ ] Enable HTTPS enforcement

---

## 📞 Troubleshooting

### Firebase Issues
```dart
// Check authentication status
if (FirebaseService.isUserAuthenticated()) {
  print('User is logged in');
} else {
  print('User needs to login');
}

// Current user
final currentUser = FirebaseService.getCurrentUser();
print('Current user: ${currentUser?.email}');
```

### XLM-RoBERTa Issues
```dart
// Grammar checking returns null
if (result == null) {
  print('Grammar check failed - check network connection');
  print('Or API token might be invalid');
}

// Questions not generating
if (questions.isEmpty) {
  print('No questions generated - check language parameter');
  print('Use "urdu" or "punjabi" only');
}
```

---

## 📖 Additional Resources

- **Firebase**: https://firebase.google.com/docs
- **Hugging Face XLM-RoBERTa**: https://huggingface.co/xlm-roberta-base
- **Flutter Docs**: https://flutter.dev/docs
- **Dart Language**: https://dart.dev/guides

---

**App Status**: ✅ Built Successfully
**Features**: ✅ Bilingual UI, Firebase Auth, XLM-RoBERTa Integration
**Ready for**: Development & Testing
