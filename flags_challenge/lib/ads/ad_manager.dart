import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// معرّفات الإعلانات. القيم الحالية هي معرّفات Google التجريبية الرسمية،
/// استبدلها بمعرّفاتك من حساب AdMob قبل النشر على Google Play.
class AdIds {
  static const banner = 'ca-app-pub-3940256099942544/6300978111';
  static const interstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const rewarded = 'ca-app-pub-3940256099942544/5224354917';
}

class AdManager {
  AdManager._();
  static final instance = AdManager._();

  /// يُعرض إعلان بيني بعد كل هذا العدد من الجولات المنتهية.
  static const interstitialEvery = 3;

  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  int _finishedRounds = 0;

  Future<void> init() async {
    await MobileAds.instance.initialize();
    _loadInterstitial();
    _loadRewarded();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (e) {
          debugPrint('Interstitial failed: $e');
          _interstitial = null;
        },
      ),
    );
  }

  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: AdIds.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewarded = ad,
        onAdFailedToLoad: (e) {
          debugPrint('Rewarded failed: $e');
          _rewarded = null;
        },
      ),
    );
  }

  bool get rewardedReady => _rewarded != null;

  /// يُستدعى عند انتهاء كل جولة، ويعرض إعلاناً بينياً كل [interstitialEvery] جولات.
  /// [onDone] يُستدعى بعد إغلاق الإعلان (أو فوراً إن لم يُعرض).
  void onRoundFinished(VoidCallback onDone) {
    _finishedRounds++;
    final ad = _interstitial;
    if (_finishedRounds % interstitialEvery != 0 || ad == null) {
      onDone();
      return;
    }
    _interstitial = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitial();
        onDone();
      },
      onAdFailedToShowFullScreenContent: (ad, e) {
        ad.dispose();
        _loadInterstitial();
        onDone();
      },
    );
    ad.show();
  }

  /// يعرض إعلان مكافأة. [onReward] يُستدعى فقط إذا أكمل اللاعب المشاهدة،
  /// و[onClosed] يُستدعى دائماً عند إغلاق الإعلان.
  void showRewarded({
    required VoidCallback onReward,
    required VoidCallback onClosed,
  }) {
    final ad = _rewarded;
    if (ad == null) {
      _loadRewarded();
      onClosed();
      return;
    }
    _rewarded = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewarded();
        onClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, e) {
        ad.dispose();
        _loadRewarded();
        onClosed();
      },
    );
    ad.show(onUserEarnedReward: (_, _) => onReward());
  }
}
