import 'dart:async';

import 'package:flutter/material.dart';

import '../ads/ad_manager.dart';
import '../game/progress.dart';

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

/// يعرض إعلان مكافأة ويُرجع true إذا أكمله اللاعب.
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
