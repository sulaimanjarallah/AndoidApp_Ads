import 'dart:math';

const capacity = 4;
const maxColors = 12;

/// حالة الأنابيب: كل أنبوب قائمة ألوان من الأسفل إلى الأعلى.
class Puzzle {
  final List<List<int>> tubes;

  Puzzle(this.tubes);

  Puzzle copy() => Puzzle([for (final t in tubes) List.of(t)]);

  bool canPour(int from, int to) {
    if (from == to) return false;
    final a = tubes[from], b = tubes[to];
    if (a.isEmpty || b.length >= capacity) return false;
    return b.isEmpty || b.last == a.last;
  }

  /// يسكب أكبر عدد ممكن من نفس اللون من أعلى [from] إلى [to].
  int pour(int from, int to) {
    if (!canPour(from, to)) return 0;
    final a = tubes[from], b = tubes[to];
    final color = a.last;
    var moved = 0;
    while (a.isNotEmpty && a.last == color && b.length < capacity) {
      b.add(a.removeLast());
      moved++;
    }
    return moved;
  }

  static bool _done(List<int> t) =>
      t.isEmpty || (t.length == capacity && t.every((c) => c == t.first));

  bool get solved => tubes.every(_done);

  String get _key => (tubes.map((t) => t.join(',')).toList()..sort()).join('|');

  /// يبحث عن حل بعمق أول، ويرجع false إذا لم يجد حلاً ضمن [limit] حالة.
  bool solvable({int limit = 100000}) {
    final seen = <String>{};
    bool dfs(Puzzle p) {
      if (p.solved) return true;
      if (seen.length > limit || !seen.add(p._key)) return false;
      for (var from = 0; from < p.tubes.length; from++) {
        final a = p.tubes[from];
        if (a.isEmpty || _done(a)) continue;
        final uniform = a.every((c) => c == a.first);
        for (var to = 0; to < p.tubes.length; to++) {
          if (!p.canPour(from, to)) continue;
          // نقل أنبوب بلون واحد إلى أنبوب فارغ لا يفيد.
          if (uniform && p.tubes[to].isEmpty) continue;
          final next = p.copy()..pour(from, to);
          if (dfs(next)) return true;
        }
      }
      return false;
    }

    return dfs(copy());
  }
}

int colorsForLevel(int level) => min(3 + (level - 1) ~/ 3, maxColors);

/// كل مرحلة ثابتة (نفس البذرة دائماً) ومضمونة الحل.
Puzzle generateLevel(int level) {
  final colors = colorsForLevel(level);
  for (var attempt = 0;; attempt++) {
    final rnd = Random(level * 7919 + attempt);
    final units = [
      for (var c = 0; c < colors; c++) ...List.filled(capacity, c)
    ]..shuffle(rnd);
    final tubes = [
      for (var t = 0; t < colors; t++)
        units.sublist(t * capacity, (t + 1) * capacity),
      <int>[],
      <int>[],
    ];
    // نرفض أي أنبوب مرتب مسبقاً حتى لا تكون المرحلة سهلة.
    if (tubes.any((t) => t.isNotEmpty && t.every((c) => c == t.first))) {
      continue;
    }
    final p = Puzzle(tubes);
    if (p.solvable()) return p;
  }
}
