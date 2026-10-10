import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../ads/ad_manager.dart';
import '../game/progress.dart';
import '../game/world.dart';
import 'widgets.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  final _p = Progress.instance;
  World? _world;
  late final Ticker _ticker = createTicker(_tick);
  Duration _last = Duration.zero;
  int _dir = 0;
  bool _reviveUsed = false;
  bool _ended = false;
  bool _newRecord = false;

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _start(Size size) {
    _world = World(size.width, size.height);
    _reviveUsed = false;
    _ended = false;
    _newRecord = false;
    _last = Duration.zero;
    if (!_ticker.isActive) _ticker.start();
  }

  void _tick(Duration elapsed) {
    final w = _world;
    if (w == null) return;
    final dt = _last == Duration.zero
        ? 0.0
        : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    w.update(dt, _dir);
    if (w.over && !_ended) _gameOver();
    setState(() {});
  }

  void _gameOver() {
    _ended = true;
    _ticker.stop();
    _last = Duration.zero;
    final w = _world!;
    _p.addCoins(w.coins);
    _newRecord = _p.submit(w.score);
  }

  Future<void> _revive() async {
    if (!await payOrWatch(context, Progress.reviveCost, 'كمّل اللعب')) return;
    if (!mounted) return;
    setState(() {
      _reviveUsed = true;
      _ended = false;
      _world!
        ..coins = 0
        ..revive();
    });
    _ticker.start();
  }

  void _leave(VoidCallback then) =>
      AdManager.instance.onRoundFinished(() {
        if (mounted) then();
      });

  void _touch(Offset pos, double width) =>
      setState(() => _dir = pos.dx < width / 2 ? -1 : 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, c) {
        final size = c.biggest;
        if (_world == null) _start(size);
        final w = _world!;
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanDown: (d) => _touch(d.localPosition, size.width),
                onPanUpdate: (d) => _touch(d.localPosition, size.width),
                onPanEnd: (_) => setState(() => _dir = 0),
                onPanCancel: () => setState(() => _dir = 0),
                child: CustomPaint(painter: _WorldPainter(w)),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                    const Spacer(),
                    Text('${w.score}',
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [Shadow(blurRadius: 6)])),
                    const Spacer(),
                    Chip(label: Text('🪙 ${w.coins}')),
                  ],
                ),
              ),
            ),
            if (_ended) _overlay(w, size),
          ],
        );
      }),
    );
  }

  Widget _overlay(World w, Size size) {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Card(
        margin: const EdgeInsets.all(32),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_newRecord ? '🏆 رقم قياسي!' : 'انتهت الجولة',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('${w.score}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text('أفضل نتيجة: ${_p.best} • جمعت ${w.coins} 🪙',
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              if (!_reviveUsed)
                FilledButton.icon(
                  onPressed: _revive,
                  icon: const Icon(Icons.favorite),
                  label: Text('كمّل من مكانك ${Progress.reviveCost}🪙 أو إعلان'),
                ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => _leave(() => setState(() => _start(size))),
                child: const Text('العب مرة أخرى'),
              ),
              TextButton(
                onPressed: () => _leave(() => Navigator.of(context).pop()),
                child: const Text('الرئيسية'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorldPainter extends CustomPainter {
  final World w;

  _WorldPainter(this.w);

  static final _colors = {
    PlatformKind.normal: const Color(0xFF43A047),
    PlatformKind.moving: const Color(0xFF1E88E5),
    PlatformKind.breaking: const Color(0xFF8D6E63),
    PlatformKind.spring: const Color(0xFF43A047),
  };

  void _emoji(Canvas canvas, String s, double size, Offset at) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(fontSize: size)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // السماء تغمق كلما ارتفعت.
    final t = (w.score / 4000).clamp(0.0, 1.0);
    final top = Color.lerp(const Color(0xFF64B5F6), const Color(0xFF1A237E), t)!;
    final bottom =
        Color.lerp(const Color(0xFFE3F2FD), const Color(0xFF5C6BC0), t)!;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(Offset.zero & size),
    );

    for (final p in w.platforms) {
      final y = p.y - w.cameraY;
      if (y < -20 || y > size.height + 20) continue;
      final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(p.x, y, p.width, World.platformHeight),
          const Radius.circular(7));
      canvas.drawRRect(
          rect,
          Paint()
            ..color = _colors[p.kind]!
                .withValues(alpha: p.broken ? 0.4 : 1));
      if (p.kind == PlatformKind.spring) {
        canvas.drawRect(
            Rect.fromLTWH(p.x + p.width / 2 - 9, y - 8, 18, 8),
            Paint()..color = const Color(0xFFFDD835));
      }
      if (p.kind == PlatformKind.breaking && !p.broken) {
        canvas.drawLine(
            Offset(p.x + p.width / 2, y),
            Offset(p.x + p.width / 2 + 4, y + World.platformHeight),
            Paint()
              ..color = Colors.black38
              ..strokeWidth = 2);
      }
      if (p.hasCoin) _emoji(canvas, '🪙', 20, Offset(p.x + p.width / 2 - 12, y - 30));
    }

    final py = w.py - w.cameraY;
    _emoji(canvas, '🐥', World.playerSize * 0.85, Offset(w.px, py));
    // عند عبور الحافة يظهر جزء اللاعب من الجهة الأخرى.
    if (w.px + World.playerSize > size.width) {
      _emoji(canvas, '🐥', World.playerSize * 0.85, Offset(w.px - size.width, py));
    }
  }

  @override
  bool shouldRepaint(_WorldPainter old) => true;
}
