import 'dart:math';

import '../data/countries.dart';

enum QuizMode { flagToCountry, countryToCapital }

const modeNames = {
  QuizMode.flagToCountry: 'خمّن الدولة من العلم',
  QuizMode.countryToCapital: 'ما هي العاصمة؟',
};

class Question {
  final Country country;
  final List<String> options;
  final String answer;

  const Question(this.country, this.options, this.answer);
}

/// يبني جولة من [length] سؤالاً بلا تكرار، لكل سؤال أربعة خيارات مختلفة.
List<Question> buildRound(QuizMode mode, Region? region,
    {int length = 10, Random? random}) {
  final rnd = random ?? Random();
  final pool = region == null
      ? List.of(countries)
      : countries.where((c) => c.inRegion(region)).toList();
  pool.shuffle(rnd);

  String label(Country c) =>
      mode == QuizMode.flagToCountry ? c.name : c.capital;

  // نأخذ الخيارات الخاطئة من نفس المنطقة لتكون أصعب، ومن كل الدول إن لم تكفِ.
  final distractorPool = pool.length >= 4 ? pool : countries;

  return pool.take(min(length, pool.length)).map((c) {
    final answer = label(c);
    final options = <String>{answer};
    final candidates = List.of(distractorPool)..shuffle(rnd);
    for (final other in [...candidates, ...countries]) {
      if (options.length == 4) break;
      options.add(label(other));
    }
    final list = options.toList()..shuffle(rnd);
    return Question(c, list, answer);
  }).toList();
}

/// نقاط السؤال: ١٠ للإجابة الصحيحة + ثانية لكل ثانية متبقية + مكافأة السلسلة.
int pointsFor({required int secondsLeft, required int streak}) =>
    10 + secondsLeft + (streak >= 3 ? 5 : 0);
