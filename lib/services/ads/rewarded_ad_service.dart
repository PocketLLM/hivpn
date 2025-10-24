import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../l10n/app_localizations.dart';

class RewardedAdService {
  RewardedAdService();

  RewardedAd? _loadedAd;
  Completer<void>? _unlockCompleter;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  Future<void> _loadAd(AppLocalizations l10n) async {
    final completer = Completer<void>();
    RewardedAd.load(
      adUnitId: _testAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _loadedAd = ad;
          completer.complete();
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error');
          completer.completeError(Exception(l10n.adFailedToLoad));
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

    final l10n = AppLocalizations.of(context);

    try {
      await _loadAd(l10n);
    } catch (e) {
      _unlockCompleter!
          .completeError(Exception(l10n.adFailedToLoad));
      _unlockCompleter = null;
      rethrow;
    }

    final ad = _loadedAd;
    if (ad == null) {
      _unlockCompleter!.completeError(Exception(l10n.adNotReady));
      _unlockCompleter = null;
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!(_unlockCompleter?.isCompleted ?? true)) {
          _unlockCompleter!
              .completeError(Exception(l10n.adMustComplete));
        }
        _loadedAd = null;
        _unlockCompleter = null;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        debugPrint('RewardedAd failed to show: $error');
        if (!(_unlockCompleter?.isCompleted ?? true)) {
          _unlockCompleter!.completeError(
            Exception(l10n.adFailedToShow),
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

const _testAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

final rewardedAdServiceProvider = Provider<RewardedAdService>((ref) {
  final service = RewardedAdService();
  ref.onDispose(() => service._loadedAd?.dispose());
  return service;
});
