import 'package:shared_preferences/shared_preferences.dart';

import 'quiz.dart';

class Scores {
  static String _key(QuizMode mode) => 'best_${mode.name}';

  static Future<int> best(QuizMode mode) async =>
      (await SharedPreferences.getInstance()).getInt(_key(mode)) ?? 0;

  /// يحفظ النتيجة إن كانت أعلى من السابقة، ويُرجع true إذا كانت رقماً قياسياً جديداً.
  static Future<bool> submit(QuizMode mode, int score) async {
    final prefs = await SharedPreferences.getInstance();
    if (score <= (prefs.getInt(_key(mode)) ?? 0)) return false;
    await prefs.setInt(_key(mode), score);
    return true;
  }
}
