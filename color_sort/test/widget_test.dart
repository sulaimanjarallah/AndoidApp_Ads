import 'package:color_sort/game/puzzle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('levels are valid, fixed and solvable', () {
    for (var level = 1; level <= 60; level++) {
      final p = generateLevel(level);
      final colors = colorsForLevel(level);
      expect(p.tubes.length, colors + 2);
      expect(p.tubes.expand((t) => t).length, colors * capacity);
      expect(p.solved, isFalse);
      expect(p.solvable(), isTrue);
      expect(generateLevel(level).tubes, p.tubes, reason: 'level $level is stable');
    }
  });

  test('pour moves all same-colored top units that fit', () {
    final p = Puzzle([
      [0, 1, 1],
      [1],
      <int>[],
    ]);
    expect(p.canPour(0, 1), isTrue);
    expect(p.pour(0, 1), 2);
    expect(p.tubes[1], [1, 1, 1]);
    expect(p.canPour(0, 1), isFalse);
    expect(p.pour(0, 2), 1);
  });

  test('solved detection', () {
    expect(Puzzle([[0, 0, 0, 0], [], [1, 1, 1, 1]]).solved, isTrue);
    expect(Puzzle([[0, 0, 0], [0], []]).solved, isFalse);
  });
}
