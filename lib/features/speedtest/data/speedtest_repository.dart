import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SpeedTestConfig {
  SpeedTestConfig({
    required this.downloadEndpoints,
    required this.uploadEndpoints,
    required this.pingEndpoints,
    required this.ipEndpoint,
  });

  final List<Uri> downloadEndpoints;
  final List<Uri> uploadEndpoints;
  final List<Uri> pingEndpoints;
  final Uri ipEndpoint;

  Uri? get firstDownload => downloadEndpoints.isNotEmpty ? downloadEndpoints.first : null;
  Uri? get firstUpload => uploadEndpoints.isNotEmpty ? uploadEndpoints.first : null;
  Uri? get firstPing => pingEndpoints.isNotEmpty ? pingEndpoints.first : null;
}

class SpeedTestRepository {
  const SpeedTestRepository();

  Future<SpeedTestConfig> load() async {
    final raw = await rootBundle.loadString('assets/speedtest_endpoints.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    final downloads = (data['download'] as List<dynamic>? ?? [])
        .map((e) => Uri.parse(e as String))
        .toList();
    final uploads = (data['upload'] as List<dynamic>? ?? [])
        .map((e) => Uri.parse(e as String))
        .toList();
    final pings = (data['ping'] as List<dynamic>? ?? [])
        .map((e) => Uri.parse(e as String))
        .toList();
    final ipEndpoint = Uri.parse((data['ip'] as String?) ?? 'https://api64.ipify.org?format=text');
    return SpeedTestConfig(
      downloadEndpoints: downloads,
      uploadEndpoints: uploads,
      pingEndpoints: pings,
      ipEndpoint: ipEndpoint,
    );
  }
}

final speedTestRepositoryProvider = Provider<SpeedTestRepository>((ref) {
  return const SpeedTestRepository();
});

final speedTestConfigProvider = FutureProvider<SpeedTestConfig>((ref) async {
  final repo = ref.watch(speedTestRepositoryProvider);
  return repo.load();
});
