import 'dart:math';

import 'package:flags_challenge/data/countries.dart';
import 'package:flags_challenge/game/modes.dart';
import 'package:flags_challenge/game/quiz.dart';
import 'package:flutter_test/flutter_test.dart';

void expectValid(Question q) {
  expect(q.options.length, 4);
  expect(q.options.toSet().length, 4);
  expect(q.options, contains(q.answer));
}

void main() {
  test('country codes are unique and valid', () {
    final codes = countries.map((c) => c.code).toSet();
    expect(codes.length, countries.length);
    expect(codes.every((c) => RegExp(r'^[A-Z]{2}$').hasMatch(c)), isTrue);
    expect(countries.every((c) => c.tier >= 1 && c.tier <= 3), isTrue);
  });

  test('every level produces 10 valid, non-repeating questions', () {
    for (var level = 1; level <= levelCount; level++) {
      final deck = levelSetup(level).deck;
      final codes = <String>{};
      for (var i = 0; i < levelLength; i++) {
        final q = deck.next()!;
        expectValid(q);
        codes.add(q.country.code);
      }
      expect(codes.length, levelLength, reason: 'level $level');
      expect(deck.next(), isNull);
    }
  });

  test('survival keeps producing questions', () {
    final deck = survivalSetup().deck;
    for (var i = 0; i < 300; i++) {
      expectValid(deck.next()!);
    }
  });

  test('daily challenge is the same for everyone on the same day', () {
    List<String> run(DateTime d) {
      final deck = dailySetup(d).deck;
      return [for (var i = 0; i < dailyLength; i++) deck.next()!.answer];
    }

    final day = DateTime(2026, 10, 10);
    expect(run(day), run(day));
    expect(run(day), isNot(run(DateTime(2026, 10, 11))));
  });

  test('practice works for every type and region', () {
    for (final t in QType.values) {
      for (final r in [null, ...Region.values]) {
        final deck = practiceSetup(t, r).deck;
        Question? q;
        while ((q = deck.next()) != null) {
          expectValid(q!);
          expect(q.type, t);
          if (r != null) expect(q.country.inRegion(r), isTrue);
        }
      }
    }
  });

  test('stars thresholds', () {
    expect(starsFor(6), 0);
    expect(starsFor(7), 1);
    expect(starsFor(9), 2);
    expect(starsFor(10), 3);
  });

  test('random questions are always valid', () {
    final rnd = Random(1);
    for (final c in countries) {
      for (final t in QType.values) {
        expectValid(buildQuestion(c, t, rnd, hard: true));
      }
    }
  });
}
