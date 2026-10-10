import 'package:flutter/material.dart';

import '../ads/banner_slot.dart';
import '../game/progress.dart';
import 'game_screen.dart';
import 'widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _p = Progress.instance;

  Future<void> _play() async {
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => GameScreen(level: _p.level)));
    if (mounted) setState(() {});
  }

  Future<void> _freeCoins() async {
    if (await watchRewardedAd(context)) {
      _p.addCoins(Progress.adCoins);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('+${Progress.adCoins} 🪙')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: const [CoinBadge(), SizedBox(width: 12)]),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (final c in palette.take(4))
                          Container(
                            margin: const EdgeInsets.all(4),
                            width: 26,
                            height: 70,
                            decoration: BoxDecoration(
                              color: c,
                              borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(13)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('فرز الألوان',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('رتّب الألوان حتى يصير كل أنبوب بلون واحد',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 40),
                    FilledButton.icon(
                      onPressed: _play,
                      icon: const Icon(Icons.play_arrow),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text('العب المرحلة ${_p.level}',
                            style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _freeCoins,
                      icon: const Icon(Icons.ondemand_video),
                      label: Text('شاهد إعلاناً واربح ${Progress.adCoins} 🪙'),
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
