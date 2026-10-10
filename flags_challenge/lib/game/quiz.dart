import 'dart:math';

import '../data/countries.dart';

enum QType { flagToCountry, countryToFlag, countryToCapital, capitalToCountry }

const qTypeNames = {
  QType.flagToCountry: 'خمّن الدولة من العلم',
  QType.countryToFlag: 'اختر العلم الصحيح',
  QType.countryToCapital: 'ما هي العاصمة؟',
  QType.capitalToCountry: 'عاصمة أي دولة؟',
};

class Question {
  final Country country;
  final QType type;
  final List<String> options;
  final String answer;

  const Question(this.country, this.type, this.options, this.answer);

  /// الخيارات أعلام (رموز تعبيرية) وليست نصوصاً.
  bool get optionsAreFlags => type == QType.countryToFlag;

  /// الرمز الكبير أعلى السؤال، إن وُجد.
  String? get bigFlag => switch (type) {
        QType.flagToCountry || QType.countryToCapital => country.flag,
        _ => null,
      };

  String get prompt => switch (type) {
        QType.flagToCountry => 'علم أي دولة هذا؟',
        QType.countryToFlag => 'أين علم ${country.name}؟',
        QType.countryToCapital => 'ما عاصمة ${country.name}؟',
        QType.capitalToCountry => '${country.capital} عاصمة أي دولة؟',
      };
}

String _label(Country c, QType type) => switch (type) {
      QType.flagToCountry || QType.capitalToCountry => c.name,
      QType.countryToCapital => c.capital,
      QType.countryToFlag => c.flag,
    };

/// يبني سؤالاً بأربعة خيارات مختلفة. عند [hard] تكون الخيارات الخاطئة
/// من نفس منطقة الدولة، فتتشابه الأعلام والأسماء ويصعب السؤال.
Question buildQuestion(Country c, QType type, Random rnd, {bool hard = false}) {
  final answer = _label(c, type);
  final near = hard
      ? (countries.where((x) => x.region == c.region && x != c).toList()
        ..shuffle(rnd))
      : <Country>[];
  final all = List.of(countries)..shuffle(rnd);
  final options = <String>{answer};
  for (final other in [...near, ...all]) {
    if (options.length == 4) break;
    options.add(_label(other, type));
  }
  return Question(c, type, options.toList()..shuffle(rnd), answer);
}

/// مصدر أسئلة لجولة كاملة أو لا نهائية، تتغير صعوبته حسب رقم السؤال.
class QuestionDeck {
  final Random rnd;

  /// عدد الأسئلة، أو null لجولة لا نهائية.
  final int? length;
  final Iterable<Country> Function(int index) poolFor;
  final List<QType> Function(int index) typesFor;
  final bool Function(int index) hardFor;

  final _used = <String>{};
  int _index = 0;

  QuestionDeck({
    required this.rnd,
    required this.length,
    required this.poolFor,
    required this.typesFor,
    required this.hardFor,
  });

  int get index => _index;

  Question? next() {
    if (length != null && _index >= length!) return null;
    var pool = poolFor(_index).where((c) => !_used.contains(c.code)).toList();
    if (pool.isEmpty) {
      _used.clear();
      pool = poolFor(_index).toList();
    }
    final c = pool[rnd.nextInt(pool.length)];
    _used.add(c.code);
    final types = typesFor(_index);
    final q = buildQuestion(c, types[rnd.nextInt(types.length)], rnd,
        hard: hardFor(_index));
    _index++;
    return q;
  }
}

Iterable<Country> tiers(int min, int max) =>
    countries.where((c) => c.tier >= min && c.tier <= max);

/// نقاط الإجابة الصحيحة: ١٠ + الثواني المتبقية + مكافأة السلسلة.
int pointsFor({required int secondsLeft, required int streak}) =>
    10 + secondsLeft + (streak >= 6 ? 10 : streak >= 3 ? 5 : 0);
