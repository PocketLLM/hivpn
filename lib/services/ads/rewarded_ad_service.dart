import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdService {
  RewardedAdService();

  RewardedAd? _loadedAd;
  Completer<void>? _unlockCompleter;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  Future<void> _loadAd() async {
    final completer = Completer<void>();
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _loadedAd = ad;
          completer.complete();
        },
        onAdFailedToLoad: (error) {
          completer.completeError(error);
        },
      ),
    );
    return completer.future;
  }

  Future<void> unlock({required Duration duration, required BuildContext context}) async {
    if (_unlockCompleter != null) {
      return _unlockCompleter!.future;
    }
    _unlockCompleter = Completer<void>();

    try {
      await _loadAd();
    } catch (e) {
      _unlockCompleter!
          .completeError(Exception('Ad failed to load. Please try again.'));
      _unlockCompleter = null;
      rethrow;
    }

    final ad = _loadedAd;
    if (ad == null) {
      _unlockCompleter!
          .completeError(Exception('Ad not ready. Please try again.'));
      _unlockCompleter = null;
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!(_unlockCompleter?.isCompleted ?? true)) {
          _unlockCompleter!
              .completeError(Exception('You must complete the ad to connect.'));
        }
        _loadedAd = null;
        _unlockCompleter = null;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        if (!(_unlockCompleter?.isCompleted ?? true)) {
          _unlockCompleter!.completeError(
            Exception('Ad failed to show. Please try again.'),
          );
        }
        _loadedAd = null;
        _unlockCompleter = null;
      },
    );

    ad.show(onUserEarnedReward: (ad, reward) {
      if (!(_unlockCompleter?.isCompleted ?? true)) {
        _unlockCompleter!.complete();
      }
    });

    await _unlockCompleter!.future;
  }
}

final rewardedAdServiceProvider = Provider<RewardedAdService>((ref) {
  final service = RewardedAdService();
  ref.onDispose(() => service._loadedAd?.dispose());
  return service;
});
