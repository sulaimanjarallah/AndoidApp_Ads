import 'package:flutter/material.dart';

import '../ads/banner_slot.dart';
import '../game/modes.dart';
import '../game/progress.dart';
import 'game_screen.dart';
import 'widgets.dart';

class LevelsScreen extends StatefulWidget {
  const LevelsScreen({super.key});

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  final _p = Progress.instance;

  Future<void> _play(int level) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => GameScreen(setup: levelSetup(level))));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('المراحل'),
        actions: const [CoinBadge(), SizedBox(width: 12)],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10),
              itemCount: levelCount,
              itemBuilder: (context, i) {
                final level = i + 1;
                final open = _p.unlocked(level);
                final stars = _p.stars(level);
                return Material(
                  color: open
                      ? (stars > 0
                          ? scheme.primaryContainer
                          : scheme.secondaryContainer)
                      : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: open ? () => _play(level) : null,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        open
                            ? Text('$level',
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold))
                            : const Icon(Icons.lock, color: Colors.grey),
                        const SizedBox(height: 4),
                        Text(
                            List.generate(3, (s) => s < stars ? '⭐' : '☆')
                                .join(),
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const BannerSlot(),
        ],
      ),
    );
  }
}
