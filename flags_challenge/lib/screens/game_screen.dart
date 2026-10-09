import 'dart:async';

import 'package:flutter/material.dart';

import '../ads/ad_manager.dart';
import '../data/countries.dart';
import '../game/quiz.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  final QuizMode mode;
  final Region? region;

  const GameScreen({super.key, required this.mode, this.region});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const secondsPerQuestion = 10;

  late final List<Question> _questions = buildRound(widget.mode, widget.region);
  int _index = 0;
  int _score = 0;
  int _correct = 0;
  int _streak = 0;
  int _secondsLeft = secondsPerQuestion;
  Timer? _timer;

  /// الإجابات المخفية بعد "حذف إجابتين" أو بعد خطأ في "الفرصة الثانية".
  final Set<String> _hidden = {};
  String? _picked;
  bool _usedFiftyFifty = false;
  bool _usedSecondChance = false;

  Question get _q => _questions[_index];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _secondsLeft = secondsPerQuestion;
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
    if (_picked != null) return;
    _timer?.cancel();
    final right = option == _q.answer;
    setState(() => _picked = option ?? '');

    if (right) {
      _streak++;
      _correct++;
      _score += pointsFor(secondsLeft: _secondsLeft, streak: _streak);
      await Future.delayed(const Duration(milliseconds: 900));
      _next();
      return;
    }

    _streak = 0;
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    if (!_usedSecondChance && AdManager.instance.rewardedReady &&
        await _askSecondChance()) {
      return;
    }
    await Future.delayed(const Duration(milliseconds: 600));
    _next();
  }

  /// يعرض على اللاعب مشاهدة إعلان مقابل إعادة المحاولة في نفس السؤال.
  Future<bool> _askSecondChance() async {
    final watch = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('فرصة ثانية؟'),
        content: const Text('شاهد إعلاناً قصيراً وأعد المحاولة في هذا السؤال.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('لا شكراً')),
          FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.ondemand_video),
              label: const Text('شاهد')),
        ],
      ),
    );
    if (watch != true) return false;

    final completer = Completer<bool>();
    var rewarded = false;
    AdManager.instance.showRewarded(
      onReward: () => rewarded = true,
      onClosed: () => completer.complete(rewarded),
    );
    if (!await completer.future || !mounted) return false;

    setState(() {
      _usedSecondChance = true;
      if (_picked != null && _picked!.isNotEmpty) _hidden.add(_picked!);
      _picked = null;
      _secondsLeft = secondsPerQuestion;
    });
    _resumeTimer();
    return true;
  }

  void _fiftyFifty() {
    if (!AdManager.instance.rewardedReady) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('الإعلان غير جاهز بعد، حاول بعد قليل')));
      return;
    }
    _timer?.cancel();
    AdManager.instance.showRewarded(
      onReward: () {
        final wrong = _q.options.where((o) => o != _q.answer).toList()
          ..shuffle();
        setState(() {
          _usedFiftyFifty = true;
          _hidden.addAll(wrong.take(2));
        });
      },
      onClosed: () {
        if (mounted && _picked == null) _resumeTimer();
      },
    );
  }

  void _next() {
    if (!mounted) return;
    if (_index + 1 >= _questions.length) {
      AdManager.instance.onRoundFinished(() {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => ResultScreen(
            mode: widget.mode,
            region: widget.region,
            score: _score,
            correct: _correct,
            total: _questions.length,
          ),
        ));
      });
      return;
    }
    setState(() {
      _index++;
      _picked = null;
      _hidden.clear();
    });
    _startTimer();
  }

  Color? _optionColor(String option, ColorScheme scheme) {
    if (_picked == null) return null;
    if (option == _q.answer) return Colors.green.shade400;
    if (option == _picked) return Colors.red.shade400;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isFlagMode = widget.mode == QuizMode.flagToCountry;

    return Scaffold(
      appBar: AppBar(
        title: Text('سؤال ${_index + 1} من ${_questions.length}'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text('⭐ $_score',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: _secondsLeft / secondsPerQuestion,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
                color: _secondsLeft <= 3 ? Colors.red : scheme.primary,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('⏱️ $_secondsLeft'),
                  if (_streak >= 3) Text('🔥 سلسلة $_streak'),
                ],
              ),
              const Spacer(),
              Text(_q.country.flag,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 120)),
              const SizedBox(height: 8),
              Text(
                isFlagMode ? 'علم أي دولة هذا؟' : 'ما عاصمة ${_q.country.name}؟',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              for (final option in _q.options)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: _hidden.contains(option) ? 0 : 1,
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        backgroundColor: _optionColor(option, scheme),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _picked != null || _hidden.contains(option)
                          ? null
                          : () => _onAnswer(option),
                      child: Text(option, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _usedFiftyFifty || _picked != null
                    ? null
                    : _fiftyFifty,
                icon: const Icon(Icons.ondemand_video),
                label: const Text('احذف إجابتين (شاهد إعلاناً)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
