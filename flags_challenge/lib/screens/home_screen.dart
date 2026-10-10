import 'package:flutter/material.dart';

import '../ads/banner_slot.dart';
import '../game/modes.dart';
import '../game/progress.dart';
import 'game_screen.dart';
import 'levels_screen.dart';
import 'practice_screen.dart';
import 'widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _p = Progress.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_p.claimLoginBonus() && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'مكافأة الدخول اليومي: +${Progress.dailyLoginBonus} 🪙')));
      }
    });
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
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
    final daily = _p.dailyPlayedToday;
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحدي الأعلام'),
        actions: const [CoinBadge(), SizedBox(width: 12)],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('🌍', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 12),
                  _ModeCard(
                    emoji: '🗺️',
                    title: 'المراحل',
                    subtitle:
                        '$levelCount مرحلة تصعب تدريجياً • ⭐ ${_p.totalStars} من ${levelCount * 3}',
                    onTap: () => _open(const LevelsScreen()),
                  ),
                  _ModeCard(
                    emoji: '❤️',
                    title: 'تحدي البقاء',
                    subtitle:
                        '٣ محاولات وأسئلة بلا نهاية • أفضل نتيجة ${_p.best('survival')}',
                    onTap: () => _open(GameScreen(setup: survivalSetup())),
                  ),
                  _ModeCard(
                    emoji: '📅',
                    title: 'التحدي اليومي',
                    subtitle: daily
                        ? 'لعبته اليوم: ${_p.dailyScore} نقطة • ارجع بكرة'
                        : '$dailyLength سؤالاً جديداً كل يوم • +20 🪙',
                    enabled: !daily,
                    onTap: () =>
                        _open(GameScreen(setup: dailySetup(DateTime.now()))),
                  ),
                  _ModeCard(
                    emoji: '🎯',
                    title: 'تدريب حر',
                    subtitle: 'اختر نوع السؤال والمنطقة',
                    onTap: () => _open(const PracticeScreen()),
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
            const BannerSlot(),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  const _ModeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        enabled: enabled,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Text(emoji, style: const TextStyle(fontSize: 34)),
        title: Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_left),
        onTap: enabled ? onTap : null,
      ),
    );
  }
}
