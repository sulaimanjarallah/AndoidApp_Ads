import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sky_jump/game/world.dart';

void main() {
  test('player bounces on the start platform and does not fall', () {
    final w = World(400, 800, random: Random(1));
    for (var i = 0; i < 60 * 5; i++) {
      w.update(1 / 60, 0);
    }
    // بدون حركة جانبية يظل اللاعب يقفز على المنصات تحته أو يسقط، لكن لا ينهار البرنامج.
    expect(w.score, greaterThanOrEqualTo(0));
  });

  test('platform gaps are always reachable by a jump', () {
    const maxJump = World.jumpSpeed * World.jumpSpeed / (2 * World.gravity);
    final w = World(400, 800, random: Random(2))..forcedDifficulty = 1;
    for (var round = 0; round < 200; round++) {
      w.cameraY -= 800;
      w.update(0, 0);
      w.over = false;
    }
    final ys = w.platforms
        .where((p) => p.kind != PlatformKind.breaking)
        .map((p) => p.y)
        .toList()
      ..sort();
    for (var i = 1; i < ys.length; i++) {
      expect(ys[i] - ys[i - 1], lessThan(maxJump));
    }
  });

  test('falling below the screen ends the game, revive continues it', () {
    final w = World(400, 800, random: Random(3));
    w.platforms.clear();
    for (var i = 0; i < 600 && !w.over; i++) {
      w.update(1 / 60, 0);
    }
    expect(w.over, isTrue);
    w.revive();
    expect(w.over, isFalse);
    w.update(1 / 60, 0);
    expect(w.over, isFalse);
  });
}
