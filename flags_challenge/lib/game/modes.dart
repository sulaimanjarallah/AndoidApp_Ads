import 'dart:math';

import '../data/countries.dart';
import 'quiz.dart';

enum GameKind { level, survival, daily, practice }

class GameSetup {
  final GameKind kind;
  final String title;
  final QuestionDeck deck;
  final int Function(int index) secondsFor;

  /// عدد المحاولات، أو 0 بلا حد.
  final int lives;
  final int? level;
  final Region? region;
  final QType? practiceType;

  const GameSetup({
    required this.kind,
    required this.title,
    required this.deck,
    required this.secondsFor,
    this.lives = 0,
    this.level,
    this.region,
    this.practiceType,
  });
}

const levelCount = 40;
const levelLength = 10;
const passScore = 7;

int starsFor(int correct) => correct >= 10
    ? 3
    : correct >= 9
        ? 2
        : correct >= passScore
            ? 1
            : 0;

/// المراحل تصعب تدريجياً: دول أقل شهرة، أنواع أسئلة أكثر، ووقت أقصر.
GameSetup levelSetup(int level) {
  final pool = level <= 6
      ? tiers(1, 1)
      : level <= 14
          ? tiers(1, 2)
          : level <= 24
              ? tiers(2, 2)
              : level <= 32
                  ? tiers(2, 3)
                  : tiers(3, 3);
  final types = level <= 4
      ? [QType.flagToCountry]
      : level <= 9
          ? [QType.flagToCountry, QType.countryToFlag]
          : level <= 16
              ? [QType.flagToCountry, QType.countryToFlag, QType.countryToCapital]
              : QType.values;
  final seconds = max(6, 12 - (level - 1) ~/ 6);
  return GameSetup(
    kind: GameKind.level,
    title: 'المرحلة $level',
    level: level,
    secondsFor: (_) => seconds,
    deck: QuestionDeck(
      rnd: Random(),
      length: levelLength,
      poolFor: (_) => pool,
      typesFor: (_) => types,
      hardFor: (_) => level >= 10,
    ),
  );
}

/// أسئلة بلا نهاية و٣ محاولات، تصعب وتسرع كلما تقدمت.
GameSetup survivalSetup() => GameSetup(
      kind: GameKind.survival,
      title: 'تحدي البقاء',
      lives: 3,
      secondsFor: (i) => max(5, 9 - i ~/ 10),
      deck: QuestionDeck(
        rnd: Random(),
        length: null,
        poolFor: (i) => i < 10
            ? tiers(1, 1)
            : i < 30
                ? tiers(1, 2)
                : tiers(1, 3),
        typesFor: (i) => i < 5 ? [QType.flagToCountry] : QType.values,
        hardFor: (i) => i >= 15,
      ),
    );

const dailyLength = 15;

int dayKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

/// نفس الأسئلة لكل اللاعبين في نفس اليوم.
GameSetup dailySetup(DateTime today) => GameSetup(
      kind: GameKind.daily,
      title: 'التحدي اليومي',
      secondsFor: (_) => 10,
      deck: QuestionDeck(
        rnd: Random(dayKey(today)),
        length: dailyLength,
        poolFor: (i) => i < 5
            ? tiers(1, 1)
            : i < 10
                ? tiers(2, 2)
                : tiers(3, 3),
        typesFor: (_) => QType.values,
        hardFor: (_) => true,
      ),
    );

GameSetup practiceSetup(QType type, Region? region) {
  final pool = region == null
      ? countries
      : countries.where((c) => c.inRegion(region)).toList();
  return GameSetup(
    kind: GameKind.practice,
    title: region == null ? 'تدريب: كل العالم' : 'تدريب: ${regionNames[region]}',
    region: region,
    practiceType: type,
    secondsFor: (_) => 10,
    deck: QuestionDeck(
      rnd: Random(),
      length: min(10, pool.length),
      poolFor: (_) => pool,
      typesFor: (_) => [type],
      hardFor: (_) => false,
    ),
  );
}
