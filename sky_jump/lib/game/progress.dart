import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Progress {
  Progress._();
  static final instance = Progress._();

  static const adCoins = 30;
  static const reviveCost = 50;

  late SharedPreferences _prefs;
  final coins = ValueNotifier<int>(0);
  int best = 0;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    coins.value = _prefs.getInt('coins') ?? 50;
    best = _prefs.getInt('best') ?? 0;
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

  bool submit(int score) {
    if (score <= best) return false;
    best = score;
    _prefs.setInt('best', best);
    return true;
  }
}
