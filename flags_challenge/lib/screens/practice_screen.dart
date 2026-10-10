import 'package:flutter/material.dart';

import '../ads/banner_slot.dart';
import '../data/countries.dart';
import '../game/modes.dart';
import '../game/quiz.dart';
import 'game_screen.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  QType _type = QType.flagToCountry;
  Region? _region;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('تدريب حر')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('نوع السؤال',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                for (final t in QType.values)
                  Card(
                    color: t == _type ? scheme.primaryContainer : null,
                    child: ListTile(
                      title: Text(qTypeNames[t]!),
                      trailing: t == _type
                          ? Icon(Icons.check_circle, color: scheme.primary)
                          : null,
                      onTap: () => setState(() => _type = t),
                    ),
                  ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          GameScreen(setup: practiceSetup(_type, _region)))),
                  icon: const Icon(Icons.play_arrow),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('ابدأ', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ],
            ),
          ),
          const BannerSlot(),
        ],
      ),
    );
  }
}
