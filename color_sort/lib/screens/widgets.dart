import 'dart:async';

import 'package:flutter/material.dart';

import '../ads/ad_manager.dart';
import '../game/progress.dart';

const palette = <Color>[
  Color(0xFFE53935), // أحمر
  Color(0xFF1E88E5), // أزرق
  Color(0xFF43A047), // أخضر
  Color(0xFFFDD835), // أصفر
  Color(0xFF8E24AA), // بنفسجي
  Color(0xFFFB8C00), // برتقالي
  Color(0xFF00ACC1), // سماوي
  Color(0xFFEC407A), // وردي
  Color(0xFF6D4C41), // بني
  Color(0xFFC0CA33), // زيتي
  Color(0xFF3949AB), // نيلي
  Color(0xFFBDBDBD), // رمادي
];

class CoinBadge extends StatelessWidget {
  const CoinBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: Progress.instance.coins,
      builder: (context, coins, _) => Chip(
        avatar: const Text('🪙'),
        label: Text('$coins',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

Future<bool> watchRewardedAd(BuildContext context) async {
  if (!AdManager.instance.rewardedReady) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('الإعلان غير جاهز بعد، حاول بعد قليل')));
    return false;
  }
  final completer = Completer<bool>();
  var rewarded = false;
  AdManager.instance.showRewarded(
    onReward: () => rewarded = true,
    onClosed: () => completer.complete(rewarded),
  );
  return completer.future;
}

/// يدفع [cost] عملة، وإن لم تكفِ يعرض مشاهدة إعلان بدلاً منها.
Future<bool> payOrWatch(BuildContext context, int cost, String what) async {
  if (Progress.instance.spend(cost)) return true;
  final watch = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(what),
      content: Text('تحتاج $cost 🪙 وعملاتك لا تكفي. شاهد إعلاناً قصيراً واحصل عليها مجاناً.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لاحقاً')),
        FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.ondemand_video),
            label: const Text('شاهد')),
      ],
    ),
  );
  if (watch != true || !context.mounted) return false;
  return watchRewardedAd(context);
}
