import 'package:equatable/equatable.dart';

enum SplitTunnelMode { allTraffic, selectedApps }

class SplitTunnelConfig extends Equatable {
  const SplitTunnelConfig({
    this.mode = SplitTunnelMode.allTraffic,
    this.selectedPackages = const {},
  });

  final SplitTunnelMode mode;
  final Set<String> selectedPackages;

  bool get isEnabled => mode == SplitTunnelMode.selectedApps;

  SplitTunnelConfig copyWith({
    SplitTunnelMode? mode,
    Set<String>? selectedPackages,
  }) {
    return SplitTunnelConfig(
      mode: mode ?? this.mode,
      selectedPackages: selectedPackages ?? this.selectedPackages,
    );
  }

  Map<String, dynamic> toJson() => {
        'mode': mode.name,
        'packages': selectedPackages.toList(),
      };

  factory SplitTunnelConfig.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SplitTunnelConfig();
    }
    final packages = (json['packages'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toSet() ??
        <String>{};
    return SplitTunnelConfig(
      mode: SplitTunnelMode.values.firstWhere(
        (m) => m.name == json['mode'],
        orElse: () => SplitTunnelMode.allTraffic,
      ),
      selectedPackages: packages,
    );
  }

  @override
  List<Object?> get props => [mode, selectedPackages];
}
