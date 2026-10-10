import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'modes.dart';

/// كل ما يُحفظ على الجهاز: العملات، نجوم المراحل، والأرقام القياسية.
class Progress {
  Progress._();
  static final instance = Progress._();

  static const hintCost = 15;
  static const timeCost = 10;
  static const reviveCost = 50;
  static const dailyLoginBonus = 20;
  static const adCoins = 30;

  late SharedPreferences _prefs;
  final coins = ValueNotifier<int>(0);

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    coins.value = _prefs.getInt('coins') ?? 50;
  }

  void addCoins(int n) {
    coins.value += n;
    _prefs.setInt('coins', coins.value);
  }

  bool spend(int n) {
    if (coins.value < n) return false;
    addCoins(-n);
    return true;
  }

  int stars(int level) => _prefs.getInt('stars_$level') ?? 0;

  /// المرحلة مفتوحة إذا كانت الأولى أو نجح اللاعب في التي قبلها.
  bool unlocked(int level) => level == 1 || stars(level - 1) > 0;

  int get totalStars =>
      [for (var l = 1; l <= levelCount; l++) stars(l)].fold(0, (a, b) => a + b);

  /// يحفظ النجوم إن تحسنت، ويُرجع عدد النجوم الجديدة المكتسبة.
  int saveStars(int level, int stars) {
    final old = this.stars(level);
    if (stars <= old) return 0;
    _prefs.setInt('stars_$level', stars);
    return stars - old;
  }

  int best(String key) => _prefs.getInt('best_$key') ?? 0;

  bool submitBest(String key, int score) {
    if (score <= best(key)) return false;
    _prefs.setInt('best_$key', score);
    return true;
  }

  bool get dailyPlayedToday =>
      _prefs.getInt('daily_day') == dayKey(DateTime.now());
  int get dailyScore => _prefs.getInt('daily_score') ?? 0;

  void saveDaily(int score) {
    _prefs.setInt('daily_day', dayKey(DateTime.now()));
    _prefs.setInt('daily_score', score);
  }

  /// مكافأة الدخول اليومي، تُرجع true إذا أُعطيت الآن.
  bool claimLoginBonus() {
    final today = dayKey(DateTime.now());
    if (_prefs.getInt('login_day') == today) return false;
    _prefs.setInt('login_day', today);
    addCoins(dailyLoginBonus);
    return true;
  }
}
