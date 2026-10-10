import 'dart:async';

import 'package:flutter/material.dart';

import '../ads/ad_manager.dart';
import '../game/modes.dart';
import '../game/progress.dart';
import '../game/quiz.dart';
import 'result_screen.dart';
import 'widgets.dart';

class GameScreen extends StatefulWidget {
  final GameSetup setup;

  const GameScreen({super.key, required this.setup});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _p = Progress.instance;
  GameSetup get _s => widget.setup;

  late Question _q;
  int _number = 1;
  int _score = 0;
  int _correct = 0;
  int _streak = 0;
  int _coinsEarned = 0;
  late int _lives = _s.lives;
  late int _seconds;
  late int _secondsLeft;
  Timer? _timer;

  /// الخيارات المخفية بعد "حذف إجابتين" أو بعد خطأ في "الفرصة الثانية".
  final Set<String> _hidden = {};
  String? _picked;
  bool _hintUsed = false;
  bool _timeUsed = false;
  bool _secondChanceUsed = false;
  bool _reviveUsed = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _q = _s.deck.next()!;
    _startQuestion();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startQuestion() {
    _seconds = _s.secondsFor(_s.deck.index - 1);
    _secondsLeft = _seconds;
    _resumeTimer();
  }

  void _resumeTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 1) {
        _timer?.cancel();
        setState(() => _secondsLeft = 0);
        _onAnswer(null);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _onAnswer(String? option) async {
    if (_picked != null || _busy) return;
    _timer?.cancel();
    final right = option == _q.answer;
    setState(() => _picked = option ?? '');

    if (right) {
      _streak++;
      _correct++;
      _score += pointsFor(secondsLeft: _secondsLeft, streak: _streak);
      _coinsEarned++;
      _p.addCoins(1);
      await Future.delayed(const Duration(milliseconds: 700));
      _next();
      return;
    }

    _streak = 0;
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    if (_s.lives > 0) {
      setState(() => _lives--);
      if (_lives > 0) return _next();
      if (!_reviveUsed && await _offerRevive()) return;
      return _finish();
    }

    if (!_secondChanceUsed && await _offerSecondChance()) return;
    _next();
  }

  Future<bool> _offerSecondChance() async {
    if (!AdManager.instance.rewardedReady) return false;
    final yes = await _ask('فرصة ثانية؟',
        'شاهد إعلاناً قصيراً وأعد المحاولة في هذا السؤال.', 'شاهد');
    if (!yes || !mounted || !await watchRewardedAd(context)) return false;
    if (!mounted) return false;
    setState(() {
      _secondChanceUsed = true;
      if (_picked!.isNotEmpty) _hidden.add(_picked!);
      _picked = null;
      _secondsLeft = _seconds;
    });
    _resumeTimer();
    return true;
  }

  Future<bool> _offerRevive() async {
    final yes = await _ask('انتهت محاولاتك 💔',
        'كمّل من حيث وقفت بمحاولة إضافية مقابل ${Progress.reviveCost} 🪙 أو إعلان.',
        'كمّل');
    if (!yes || !mounted) return false;
    if (!await payOrWatch(context, Progress.reviveCost, 'محاولة إضافية')) {
      return false;
    }
    setState(() {
      _reviveUsed = true;
      _lives = 1;
    });
    _next();
    return true;
  }

  Future<bool> _ask(String title, String body, String action) async {
    final r = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('لا شكراً')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(action)),
        ],
      ),
    );
    return r == true;
  }

  Future<void> _useHelp(int cost, String what, VoidCallback apply) async {
    _timer?.cancel();
    setState(() => _busy = true);
    final ok = await payOrWatch(context, cost, what);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (ok) apply();
    });
    if (_picked == null) _resumeTimer();
  }

  void _removeTwo() => _useHelp(Progress.hintCost, 'حذف إجابتين', () {
        final wrong = _q.options
            .where((o) => o != _q.answer && !_hidden.contains(o))
            .toList()
          ..shuffle();
        _hidden.addAll(wrong.take(2));
        _hintUsed = true;
      });

  void _addTime() => _useHelp(Progress.timeCost, 'وقت إضافي', () {
        _secondsLeft += 5;
        _timeUsed = true;
      });

  void _next() {
    if (!mounted) return;
    final q = _s.deck.next();
    if (q == null) return _finish();
    setState(() {
      _q = q;
      _number++;
      _picked = null;
      _hidden.clear();
      _hintUsed = false;
      _timeUsed = false;
    });
    _startQuestion();
  }

  void _finish() {
    _timer?.cancel();
    final answered = _s.deck.index;
    var stars = 0;
    var newRecord = false;
    var bonus = 0;
    switch (_s.kind) {
      case GameKind.level:
        stars = starsFor(_correct);
        bonus = _p.saveStars(_s.level!, stars) * 10;
      case GameKind.survival:
        newRecord = _p.submitBest('survival', _score);
      case GameKind.daily:
        _p.saveDaily(_score);
        bonus = 20;
      case GameKind.practice:
        newRecord = _p.submitBest('practice_${_s.practiceType!.name}', _score);
    }
    if (bonus > 0) _p.addCoins(bonus);

    AdManager.instance.onRoundFinished(() {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ResultScreen(
          setup: _s,
          score: _score,
          correct: _correct,
          answered: answered,
          stars: stars,
          newRecord: newRecord,
          coins: _coinsEarned + bonus,
        ),
      ));
    });
  }

  Color? _optionColor(String option) {
    if (_picked == null) return null;
    if (option == _q.answer) return Colors.green.shade400;
    if (option == _picked) return Colors.red.shade400;
    return null;
  }

  Widget _option(String option, {required bool big}) {
    final hidden = _hidden.contains(option);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: hidden ? 0 : 1,
      child: FilledButton.tonal(
        style: FilledButton.styleFrom(
          backgroundColor: _optionColor(option),
          padding: EdgeInsets.symmetric(vertical: big ? 8 : 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: _picked != null || hidden || _busy
            ? null
            : () => _onAnswer(option),
        child: Text(option,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: big ? 56 : 18)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final length = _s.deck.length;
    final canHelp = _picked == null && !_busy;

    return Scaffold(
      appBar: AppBar(
        title: Text(_s.title),
        actions: const [CoinBadge(), SizedBox(width: 12)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(length == null
                      ? 'سؤال $_number'
                      : 'سؤال $_number من $length'),
                  const Spacer(),
                  if (_s.lives > 0)
                    Text(List.generate(
                            _s.lives, (i) => i < _lives ? '❤️' : '🤍')
                        .join()),
                  const SizedBox(width: 12),
                  Text('⭐ $_score',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_secondsLeft / _seconds).clamp(0, 1),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
                color: _secondsLeft <= 3 ? Colors.red : scheme.primary,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('⏱️ $_secondsLeft'),
                  const Spacer(),
                  if (_streak >= 3) Text('🔥 سلسلة $_streak'),
                ],
              ),
              const Spacer(),
              if (_q.bigFlag != null)
                Text(_q.bigFlag!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 110)),
              const SizedBox(height: 8),
              Text(_q.prompt,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              if (_q.optionsAreFlags)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.5,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (final o in _q.options) _option(o, big: true)
                  ],
                )
              else
                for (final o in _q.options)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _option(o, big: false),
                  ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: canHelp && !_hintUsed ? _removeTwo : null,
                      child: Text('✂️ حذف إجابتين ${Progress.hintCost}🪙'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: canHelp && !_timeUsed ? _addTime : null,
                      child: Text('⏳ +٥ ثواني ${Progress.timeCost}🪙'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
