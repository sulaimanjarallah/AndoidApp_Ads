import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Progress {
  Progress._();
  static final instance = Progress._();

  static const levelReward = 10;
  static const adCoins = 30;
  static const extraTubeCost = 40;
  static const undoPackCost = 20;
  static const freeUndos = 5;

  late SharedPreferences _prefs;
  final coins = ValueNotifier<int>(0);
  int level = 1;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    coins.value = _prefs.getInt('coins') ?? 50;
    level = _prefs.getInt('level') ?? 1;
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

  void completeLevel(int finished) {
    if (finished >= level) {
      level = finished + 1;
      _prefs.setInt('level', level);
    }
  }
}
