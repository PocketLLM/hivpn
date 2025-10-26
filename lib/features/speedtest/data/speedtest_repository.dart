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
    // Use default endpoints from flutter_speed_test_plus
    // The library uses Fast.com API by default which is reliable
    final downloads = [
      Uri.parse('https://fast.com/'),
    ];
    final uploads = [
      Uri.parse('https://fast.com/'),
    ];
    final pings = [
      Uri.parse('https://fast.com/'),
    ];
    final ipEndpoint = Uri.parse('https://api64.ipify.org?format=text');

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
