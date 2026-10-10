import 'package:flutter/material.dart';

import '../ads/banner_slot.dart';
import '../game/modes.dart';
import 'game_screen.dart';

class ResultScreen extends StatelessWidget {
  final GameSetup setup;
  final int score;
  final int correct;
  final int answered;
  final int stars;
  final bool newRecord;
  final int coins;

  const ResultScreen({
    super.key,
    required this.setup,
    required this.score,
    required this.correct,
    required this.answered,
    required this.stars,
    required this.newRecord,
    required this.coins,
  });

  bool get _isLevel => setup.kind == GameKind.level;
  bool get _passed => stars > 0;

  String get _emoji {
    if (_isLevel) return _passed ? (stars == 3 ? '🏆' : '🎉') : '😅';
    if (newRecord) return '🏆';
    return answered > 0 && correct / answered >= 0.7 ? '👏' : '💪';
  }

  GameSetup? get _again => switch (setup.kind) {
        GameKind.level => levelSetup(
            _passed && setup.level! < levelCount ? setup.level! + 1 : setup.level!),
        GameKind.survival => survivalSetup(),
        GameKind.practice => practiceSetup(setup.practiceType!, setup.region),
        GameKind.daily => null,
      };

  String get _againLabel {
    if (_isLevel) {
      return _passed && setup.level! < levelCount
          ? 'المرحلة التالية'
          : 'أعد المحاولة';
    }
    return 'العب مرة أخرى';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final again = _again;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(_emoji,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 88)),
                    Text(setup.title,
                        textAlign: TextAlign.center, style: text.titleMedium),
                    if (_isLevel)
                      Text(
                          _passed
                              ? List.generate(3, (i) => i < stars ? '⭐' : '☆')
                                  .join(' ')
                              : 'تحتاج $passScore إجابات صحيحة لتعبر المرحلة',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: _passed ? 36 : 16)),
                    if (newRecord)
                      Text('رقم قياسي جديد!',
                          textAlign: TextAlign.center,
                          style:
                              text.titleLarge?.copyWith(color: Colors.orange)),
                    const SizedBox(height: 12),
                    Text('$score نقطة',
                        textAlign: TextAlign.center,
                        style: text.displaySmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('إجابات صحيحة: $correct من $answered',
                        textAlign: TextAlign.center, style: text.titleMedium),
                    if (coins > 0)
                      Text('ربحت $coins 🪙',
                          textAlign: TextAlign.center,
                          style: text.titleMedium),
                    const SizedBox(height: 32),
                    if (again != null)
                      FilledButton.icon(
                        onPressed: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (_) => GameScreen(setup: again))),
                        icon: const Icon(Icons.play_arrow),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(_againLabel,
                              style: const TextStyle(fontSize: 18)),
                        ),
                      ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('رجوع'),
                    ),
                  ],
                ),
              ),
            ),
            const BannerSlot(),
          ],
        ),
      ),
    );
  }
}
