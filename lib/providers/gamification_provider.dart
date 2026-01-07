import 'package:flutter/foundation.dart';

class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final DateTime unlockedAt;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.unlockedAt,
  });
}

class GamificationProvider extends ChangeNotifier {
  int _totalPoints = 0;
  int _currentLevel = 1;
  int _pointsForNextLevel = 100;
  List<Badge> _unlockedBadges = [];
  int _streak = 0;
  int _currentStreak = 0;
  DateTime? _lastActiveDate;
  int _totalLessonsCompleted = 0;
  int _totalQuizzesCompleted = 0;
  double _xpMultiplier = 1.0;

  int get totalPoints => _totalPoints;
  int get currentLevel => _currentLevel;
  int get pointsForNextLevel => _pointsForNextLevel;
  List<Badge> get unlockedBadges => _unlockedBadges;
  int get streak => _streak;
  int get currentStreak => _currentStreak;
  DateTime? get lastActiveDate => _lastActiveDate;
  int get totalLessonsCompleted => _totalLessonsCompleted;
  int get totalQuizzesCompleted => _totalQuizzesCompleted;
  double get xpMultiplier => _xpMultiplier;

  void addPoints(int points) {
    final multipliedPoints = (points * _xpMultiplier).round();
    _totalPoints += multipliedPoints;
    _checkLevelUp();
    updateDailyStreak(); // Call public method
    notifyListeners();
  }

  void updateDailyStreak() {
    // Made public
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastActiveDate == null) {
      _streak = 1;
      _currentStreak = 1;
      _lastActiveDate = today;
      _updateXPMultiplier();
    } else {
      final lastActive = DateTime(
        _lastActiveDate!.year,
        _lastActiveDate!.month,
        _lastActiveDate!.day,
      );

      final difference = today.difference(lastActive).inDays;

      if (difference == 0) {
        // Same day, no change
        return;
      } else if (difference == 1) {
        // Consecutive day
        _streak++;
        _currentStreak++;
        _lastActiveDate = today;
        _checkStreakBadges();
        _updateXPMultiplier();
      } else {
        // Streak broken
        _streak = 1;
        _currentStreak = 1;
        _lastActiveDate = today;
        _xpMultiplier = 1.0;
      }
    }
  }

  void _updateXPMultiplier() {
    if (_streak >= 30) {
      _xpMultiplier = 2.0;
    } else if (_streak >= 14) {
      _xpMultiplier = 1.5;
    } else if (_streak >= 7) {
      _xpMultiplier = 1.25;
    } else {
      _xpMultiplier = 1.0;
    }
  }

  void _checkLevelUp() {
    while (_totalPoints >= _pointsForNextLevel) {
      _totalPoints -= _pointsForNextLevel;
      _currentLevel++;
      _pointsForNextLevel = (100 * _currentLevel).toInt();
    }
  }

  void _checkStreakBadges() {
    if (_streak == 3) {
      _unlockBadge(
        Badge(
          id: 'streak_3',
          name: '🔥 تین دن کی شروعات',
          description: '3 دن کی مسلسل تربیت',
          icon: '🔥',
          unlockedAt: DateTime.now(),
        ),
      );
    }
    if (_streak == 7) {
      _unlockBadge(
        Badge(
          id: 'streak_7',
          name: '⭐ ایک ہفتہ کی یادیں',
          description: '7 دن کی مسلسل تربیت',
          icon: '⭐',
          unlockedAt: DateTime.now(),
        ),
      );
    }
    if (_streak == 14) {
      _unlockBadge(
        Badge(
          id: 'streak_14',
          name: '💪 دو ہفتے کا جنگجو',
          description: '14 دن کی مسلسل تربیت - 1.5x XP!',
          icon: '💪',
          unlockedAt: DateTime.now(),
        ),
      );
    }
    if (_streak == 30) {
      _unlockBadge(
        Badge(
          id: 'streak_30',
          name: '👑 ایک ماہ کا چیمپیئن',
          description: '30 دن کی مسلسل تربیت - 2x XP!',
          icon: '👑',
          unlockedAt: DateTime.now(),
        ),
      );
    }
    if (_streak == 100) {
      _unlockBadge(
        Badge(
          id: 'streak_100',
          name: '🏆 سو دن کا لیجنڈ',
          description: '100 دن کی مسلسل تربیت - ماسٹر!',
          icon: '🏆',
          unlockedAt: DateTime.now(),
        ),
      );
    }
  }

  void completeLesson() {
    _totalLessonsCompleted++;
    addPoints(20);

    if (_totalLessonsCompleted == 10) {
      _unlockBadge(
        Badge(
          id: 'lessons_10',
          name: '📚 نوآموز طالب علم',
          description: '10 سبق مکمل کیے',
          icon: '📚',
          unlockedAt: DateTime.now(),
        ),
      );
    }
    if (_totalLessonsCompleted == 50) {
      _unlockBadge(
        Badge(
          id: 'lessons_50',
          name: '🎓 وقف علم',
          description: '50 سبق مکمل کیے',
          icon: '🎓',
          unlockedAt: DateTime.now(),
        ),
      );
    }
    notifyListeners();
  }

  void completeQuiz(double score) {
    _totalQuizzesCompleted++;
    final points = (score * 100).round();
    addPoints(points);

    if (score >= 0.9 && _totalQuizzesCompleted >= 10) {
      _unlockBadge(
        Badge(
          id: 'quiz_expert',
          name: '⚡ کوئز ماہر',
          description: '10 کوئز میں 90%+ اسکور',
          icon: '⚡',
          unlockedAt: DateTime.now(),
        ),
      );
    }
    notifyListeners();
  }

  void resetStreak() {
    _streak = 0;
    notifyListeners();
  }

  void _unlockBadge(Badge badge) {
    if (!_unlockedBadges.any((b) => b.id == badge.id)) {
      _unlockedBadges.add(badge);
      // Add bonus points for badge unlock
      addPoints(50);
    }
  }

  void unlockQuizMaster() {
    _unlockBadge(
      Badge(
        id: 'quiz_master',
        name: 'کوئز ماسٹر',
        description: '10 کوئز کو 90% سے زیادہ اسکور کریں',
        icon: '🎓',
        unlockedAt: DateTime.now(),
      ),
    );
  }

  void unlockVocabularyChampion() {
    _unlockBadge(
      Badge(
        id: 'vocab_champion',
        name: 'الفاظ کا سپاہی',
        description: '100 نئے الفاظ سیکھیں',
        icon: '📚',
        unlockedAt: DateTime.now(),
      ),
    );
  }

  void unlockPolyglot() {
    _unlockBadge(
      Badge(
        id: 'polyglot',
        name: 'بہو لسانی',
        description: 'اردو اور پنجابی دونوں میں 1000 پوائنٹس حاصل کریں',
        icon: '🌍',
        unlockedAt: DateTime.now(),
      ),
    );
  }
}
