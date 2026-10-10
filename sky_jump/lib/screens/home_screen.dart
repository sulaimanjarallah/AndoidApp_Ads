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
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const GameScreen()));
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF64B5F6), Color(0xFFE3F2FD)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CoinBadge(),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('🐥',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 90)),
                      Text('القفزة',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text(
                          'المس يمين أو يسار الشاشة لتتحرك، واطلع لأعلى ما تقدر',
                          textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text('أفضل نتيجة: ${_p.best}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 32),
                      FilledButton.icon(
                        onPressed: _play,
                        icon: const Icon(Icons.play_arrow),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text('ابدأ', style: TextStyle(fontSize: 22)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _freeCoins,
                        icon: const Icon(Icons.ondemand_video),
                        label:
                            Text('شاهد إعلاناً واربح ${Progress.adCoins} 🪙'),
                      ),
                    ],
                  ),
                ),
              ),
              const BannerSlot(),
            ],
          ),
        ),
      ),
    );
  }
}
