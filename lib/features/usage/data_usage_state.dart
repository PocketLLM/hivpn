import 'package:equatable/equatable.dart';

class DataUsageState extends Equatable {
  const DataUsageState({
    required this.periodStart,
    this.usedBytes = 0,
    this.monthlyLimitBytes,
    this.lastUpdated,
  });

  factory DataUsageState.initial() => DataUsageState(
        periodStart: DateTime.now().toUtc(),
        usedBytes: 0,
      );

  final DateTime periodStart;
  final int usedBytes;
  final int? monthlyLimitBytes;
  final DateTime? lastUpdated;

  bool get hasLimit => monthlyLimitBytes != null && monthlyLimitBytes! > 0;

  bool get limitExceeded =>
      hasLimit && usedBytes >= (monthlyLimitBytes ?? 0);

  double get utilization {
    final limit = monthlyLimitBytes;
    if (limit == null || limit <= 0) {
      return 0;
    }
    return usedBytes / limit;
  }

  DataUsageState copyWith({
    DateTime? periodStart,
    int? usedBytes,
    int? monthlyLimitBytes,
    DateTime? lastUpdated,
  }) {
    return DataUsageState(
      periodStart: periodStart ?? this.periodStart,
      usedBytes: usedBytes ?? this.usedBytes,
      monthlyLimitBytes: monthlyLimitBytes ?? this.monthlyLimitBytes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'periodStart': periodStart.toIso8601String(),
      'usedBytes': usedBytes,
      'monthlyLimitBytes': monthlyLimitBytes,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory DataUsageState.fromJson(Map<String, dynamic> json) {
    return DataUsageState(
      periodStart: DateTime.tryParse(json['periodStart'] as String? ?? '')?.toUtc() ??
          DateTime.now().toUtc(),
      usedBytes: json['usedBytes'] as int? ?? 0,
      monthlyLimitBytes: json['monthlyLimitBytes'] as int?,
      lastUpdated: DateTime.tryParse(json['lastUpdated'] as String? ?? '')?.toUtc(),
    );
  }

  @override
  List<Object?> get props => [periodStart, usedBytes, monthlyLimitBytes, lastUpdated];
}
