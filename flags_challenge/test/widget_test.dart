import 'dart:math';

import 'package:flags_challenge/data/countries.dart';
import 'package:flags_challenge/game/quiz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('country codes are unique and valid', () {
    final codes = countries.map((c) => c.code).toSet();
    expect(codes.length, countries.length);
    expect(codes.every((c) => RegExp(r'^[A-Z]{2}$').hasMatch(c)), isTrue);
  });

  for (final mode in QuizMode.values) {
    for (final region in [null, ...Region.values]) {
      test('round $mode / $region has valid questions', () {
        for (var seed = 0; seed < 20; seed++) {
          final round = buildRound(mode, region, random: Random(seed));
          expect(round, isNotEmpty);
          expect(round.map((q) => q.country.code).toSet().length,
              round.length);
          for (final q in round) {
            expect(q.options.length, 4);
            expect(q.options.toSet().length, 4);
            expect(q.options, contains(q.answer));
            if (region != null) expect(q.country.inRegion(region), isTrue);
          }
        }
      });
    }
  }
}
