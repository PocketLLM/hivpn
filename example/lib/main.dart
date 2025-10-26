import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:hivpn/l10n/app_localizations.dart';
import 'package:hivpn/services/speedtest/ndt7_service.dart';
import 'package:hivpn/widgets/speedtest_card.dart';

void main() {
  runApp(const SpeedTestExampleApp());
}

class SpeedTestExampleApp extends StatefulWidget {
  const SpeedTestExampleApp({super.key});

  @override
  State<SpeedTestExampleApp> createState() => _SpeedTestExampleAppState();
}

class _SpeedTestExampleAppState extends State<SpeedTestExampleApp> {
  late final Ndt7Service _service = Ndt7Service();

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          return Scaffold(
            appBar: AppBar(title: Text(l10n.speedTestCardTitle)),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: SpeedTestCard(service: _service),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
