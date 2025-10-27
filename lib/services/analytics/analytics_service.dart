import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalyticsService {
  const AnalyticsService();

  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]) async {
    if (kDebugMode) {
      final buffer = StringBuffer('📊 $name');
      if (parameters != null && parameters.isNotEmpty) {
        buffer.write(' => ');
        buffer.write(parameters);
      }
      debugPrint(buffer.toString());
    }
  }
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return const AnalyticsService();
});
