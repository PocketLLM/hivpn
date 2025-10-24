import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../features/session/domain/session_controller.dart';
import '../../services/ads/rewarded_ad_service.dart';
import '../../l10n/app_localizations.dart';

final extendIntentHandlerProvider = Provider<ExtendIntentHandler>((ref) {
  final handler = ExtendIntentHandler(ref);
  handler.initialize();
  ref.onDispose(handler.dispose);
  return handler;
});

class ExtendIntentHandler {
  ExtendIntentHandler(this._ref);

  final Ref _ref;
  static const _channel = MethodChannel('com.example.vpn/VpnChannel');
  bool _registered = false;

  void initialize() {
    if (_registered) return;
    _channel.setMethodCallHandler(_handleCall);
    _registered = true;
  }

  Future<void> dispose() async {
    if (_registered) {
      _channel.setMethodCallHandler(null);
      _registered = false;
    }
  }

  Future<void> _handleCall(MethodCall call) async {
    if (call.method == 'showExtendAd') {
      await _presentExtendAd();
    }
  }

  Future<void> _presentExtendAd() async {
    final navigatorKey = _ref.read(navigatorKeyProvider);
    BuildContext? context = navigatorKey.currentContext;
    var retries = 0;
    while (context == null && retries < 10) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      context = navigatorKey.currentContext;
      retries += 1;
    }
    if (context == null) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    try {
      await _ref
          .read(rewardedAdServiceProvider)
          .unlock(duration: const Duration(hours: 1), context: context);
      await _ref
          .read(sessionControllerProvider.notifier)
          .extend(const Duration(hours: 1));
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(l10n.sessionRemaining + ' +60m')),
      );
    } catch (error) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }
}
