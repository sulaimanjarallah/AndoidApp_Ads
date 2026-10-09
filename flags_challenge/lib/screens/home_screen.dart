import 'package:flutter/material.dart';

import '../ads/banner_slot.dart';
import '../data/countries.dart';
import '../game/quiz.dart';
import '../game/scores.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  QuizMode _mode = QuizMode.flagToCountry;
  Region? _region;
  int _best = 0;

  @override
  void initState() {
    super.initState();
    _loadBest();
  }

  Future<void> _loadBest() async {
    final best = await Scores.best(_mode);
    if (mounted) setState(() => _best = best);
  }

  Future<void> _start() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => GameScreen(mode: _mode, region: _region),
    ));
    _loadBest();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 12),
                  const Text('🌍', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 72)),
                  Text('تحدي الأعلام والعواصم',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('أفضل نتيجة: $_best',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.primary, fontSize: 16)),
                  const SizedBox(height: 28),
                  const Text('نوع التحدي',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  for (final m in QuizMode.values)
                    Card(
                      color: m == _mode ? scheme.primaryContainer : null,
                      child: ListTile(
                        leading: Text(
                            m == QuizMode.flagToCountry ? '🏳️' : '🏛️',
                            style: const TextStyle(fontSize: 28)),
                        title: Text(modeNames[m]!),
                        trailing: m == _mode
                            ? Icon(Icons.check_circle, color: scheme.primary)
                            : null,
                        onTap: () {
                          setState(() => _mode = m);
                          _loadBest();
                        },
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Text('المنطقة',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('كل العالم'),
                        selected: _region == null,
                        onSelected: (_) => setState(() => _region = null),
                      ),
                      for (final r in Region.values)
                        ChoiceChip(
                          label: Text(regionNames[r]!),
                          selected: _region == r,
                          onSelected: (_) => setState(() => _region = r),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: _start,
                    icon: const Icon(Icons.play_arrow),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('ابدأ', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ],
              ),
            ),
            const BannerSlot(),
          ],
        ),
      ),
    );
  }
}
