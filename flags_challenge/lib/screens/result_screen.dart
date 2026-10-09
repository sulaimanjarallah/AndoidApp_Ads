import 'package:flutter/material.dart';

import '../ads/banner_slot.dart';
import '../data/countries.dart';
import '../game/quiz.dart';
import '../game/scores.dart';
import 'game_screen.dart';

class ResultScreen extends StatefulWidget {
  final QuizMode mode;
  final Region? region;
  final int score;
  final int correct;
  final int total;

  const ResultScreen({
    super.key,
    required this.mode,
    required this.region,
    required this.score,
    required this.correct,
    required this.total,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _newRecord = false;

  @override
  void initState() {
    super.initState();
    Scores.submit(widget.mode, widget.score).then((isNew) {
      if (mounted) setState(() => _newRecord = isNew);
    });
  }

  String get _emoji {
    final ratio = widget.correct / widget.total;
    if (ratio >= 0.9) return '🏆';
    if (ratio >= 0.6) return '👏';
    return '💪';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
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
                    Text(_emoji, textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 96)),
                    if (_newRecord)
                      Text('رقم قياسي جديد!', textAlign: TextAlign.center,
                          style: text.titleLarge?.copyWith(color: Colors.orange)),
                    const SizedBox(height: 12),
                    Text('${widget.score} نقطة', textAlign: TextAlign.center,
                        style: text.displaySmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('أجبت صح على ${widget.correct} من ${widget.total}',
                        textAlign: TextAlign.center, style: text.titleMedium),
                    const SizedBox(height: 40),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => GameScreen(
                              mode: widget.mode, region: widget.region),
                        ),
                      ),
                      icon: const Icon(Icons.replay),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('العب مرة أخرى',
                            style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('القائمة الرئيسية'),
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
