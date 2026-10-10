import 'dart:math';

enum PlatformKind { normal, moving, breaking, spring }

class Platform {
  double x, y;
  final double width;
  final PlatformKind kind;
  double vx;
  bool broken = false;
  bool hasCoin;

  Platform(this.x, this.y, this.kind,
      {this.width = 72, this.vx = 0, this.hasCoin = false});
}

/// منطق اللعبة كاملاً بدون واجهة، لتسهيل اختباره.
/// الإحداثيات بالبكسل، وy يزيد نزولاً، والكاميرا تتبع اللاعب للأعلى.
class World {
  static const gravity = 1900.0;
  static const jumpSpeed = -950.0;
  static const springSpeed = -1500.0;
  static const moveSpeed = 340.0;
  static const playerSize = 44.0;
  static const platformHeight = 14.0;

  final double width, height;
  final Random rnd;

  double px = 0, py = 0, vx = 0, vy = 0;
  double cameraY = 0;
  double _highest = 0;
  int coins = 0;
  bool over = false;
  final platforms = <Platform>[];
  double _nextY = 0;

  World(this.width, this.height, {Random? random}) : rnd = random ?? Random() {
    reset();
  }

  int get score => (_highest / 10).floor();

  void reset() {
    platforms.clear();
    cameraY = 0;
    _highest = 0;
    coins = 0;
    over = false;
    final start = Platform(width / 2 - 36, height - 80, PlatformKind.normal);
    platforms.add(start);
    px = width / 2 - playerSize / 2;
    py = start.y - playerSize;
    vx = 0;
    vy = jumpSpeed;
    _nextY = start.y;
    _fill();
  }

  /// صعوبة من 0 إلى 1 تزيد مع الارتفاع.
  double get difficulty => forcedDifficulty ?? min(1, score / 3000);

  /// للاختبارات فقط: تثبيت الصعوبة.
  double? forcedDifficulty;

  void _fill() {
    while (_nextY > cameraY - height) {
      final d = difficulty;
      final gap = 65 + rnd.nextDouble() * (55 + 90 * d);
      _nextY -= gap;
      final r = rnd.nextDouble();
      final kind = r < 0.06
          ? PlatformKind.spring
          : r < 0.06 + 0.30 * d
              ? PlatformKind.moving
              : r < 0.06 + 0.30 * d + 0.22 * d
                  ? PlatformKind.breaking
                  : PlatformKind.normal;
      final w = 72.0 - 18 * d;
      final p = Platform(rnd.nextDouble() * (width - w), _nextY, kind,
          width: w,
          vx: kind == PlatformKind.moving
              ? (rnd.nextBool() ? 1 : -1) * (70 + 120 * d)
              : 0,
          hasCoin: kind != PlatformKind.breaking && rnd.nextDouble() < 0.15);
      platforms.add(p);
      // منصة مكسورة وحدها قد تجعل القفزة مستحيلة، فنضيف بجانبها منصة سليمة.
      if (kind == PlatformKind.breaking) {
        platforms.add(Platform(
            (p.x + width / 2) % (width - w), _nextY - 20, PlatformKind.normal,
            width: w));
      }
    }
    platforms.removeWhere((p) => p.y > cameraY + height + 50);
  }

  /// [dir] اتجاه اللمس: -1 يسار، 1 يمين، 0 بلا لمس.
  void update(double dt, int dir) {
    if (over) return;
    dt = min(dt, 1 / 30);

    vx = dir * moveSpeed;
    px += vx * dt;
    // الخروج من جهة يدخل من الجهة الأخرى.
    if (px < -playerSize / 2) px += width;
    if (px > width - playerSize / 2) px -= width;

    final prevBottom = py + playerSize;
    vy += gravity * dt;
    py += vy * dt;
    final bottom = py + playerSize;

    for (final p in platforms) {
      if (p.kind == PlatformKind.moving) {
        p.x += p.vx * dt;
        if (p.x < 0 || p.x + p.width > width) {
          p.vx = -p.vx;
          p.x = p.x.clamp(0, width - p.width);
        }
      }
    }

    if (vy > 0) {
      for (final p in platforms) {
        if (p.broken) continue;
        final overX = px + playerSize * 0.8 > p.x && px + playerSize * 0.2 < p.x + p.width;
        if (overX && prevBottom <= p.y && bottom >= p.y) {
          if (p.kind == PlatformKind.breaking) {
            p.broken = true;
            continue;
          }
          py = p.y - playerSize;
          vy = p.kind == PlatformKind.spring ? springSpeed : jumpSpeed;
          if (p.hasCoin) {
            p.hasCoin = false;
            coins++;
          }
          break;
        }
      }
    }

    for (final p in platforms) {
      if (p.broken) p.y += 600 * dt;
    }

    final climbed = (height - 80 - py);
    if (climbed > _highest) _highest = climbed;

    final target = py - height * 0.4;
    if (target < cameraY) cameraY = target;
    _fill();

    if (py > cameraY + height) over = true;
  }

  /// يكمل اللعب بعد الخسارة: منصة جديدة تحت اللاعب وقفزة قوية.
  void revive() {
    final p = Platform(
        (px + playerSize / 2 - 50).clamp(0, width - 100), cameraY + height - 120,
        PlatformKind.normal,
        width: 100);
    platforms.add(p);
    py = p.y - playerSize;
    vy = springSpeed;
    over = false;
  }
}
