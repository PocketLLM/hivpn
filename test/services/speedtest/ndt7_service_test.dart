import 'package:flutter_test/flutter_test.dart';

import 'package:hivpn/services/speedtest/ndt7_models.dart';

void main() {
  group('Ndt7ServerMetrics', () {
    test('parses nested metrics from JSON messages', () {
      final json = <String, dynamic>{
        'Origin': 'server',
        'Test': 'download',
        'AppInfo': {
          'ElapsedTime': 1200000,
          'NumBytes': 5242880,
          'MeanThroughputMbps': 85.42,
          'LossRate': 0.0123,
        },
        'TCPInfo': {
          'MinRTT': 145678,
        },
        'Nested': {
          'Inner': {
            'LossRate': 0.04,
          },
        },
      };

      final metrics = Ndt7ServerMetrics.fromJson(json);

      expect(metrics.meanThroughputMbps, closeTo(85.42, 1e-9));
      expect(metrics.lossRate, closeTo(0.04, 1e-9));
      expect(metrics.minRttMs, closeTo(145.678, 1e-3));
    });
  });

  group('computeThroughputMbps', () {
    test('returns zero when duration is zero or negative', () {
      expect(computeThroughputMbps(1000, 0), 0);
      expect(computeThroughputMbps(0, 1000), 0);
    });

    test('calculates megabits per second from bytes and microseconds', () {
      final bytesTransferred = 1250000; // 10 megabits
      final elapsedMicros = 1000000; // 1 second

      final mbps = computeThroughputMbps(bytesTransferred, elapsedMicros);

      expect(mbps, closeTo(10, 1e-9));
    });
  });
}
