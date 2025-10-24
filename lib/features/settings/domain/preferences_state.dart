import 'package:equatable/equatable.dart';

class PreferencesState extends Equatable {
  const PreferencesState({
    this.autoServerSwitch = true,
    this.hapticsEnabled = true,
    this.localeCode,
  });

  final bool autoServerSwitch;
  final bool hapticsEnabled;
  final String? localeCode;

  PreferencesState copyWith({
    bool? autoServerSwitch,
    bool? hapticsEnabled,
    String? localeCode,
  }) {
    return PreferencesState(
      autoServerSwitch: autoServerSwitch ?? this.autoServerSwitch,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      localeCode: localeCode ?? this.localeCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoServerSwitch': autoServerSwitch,
      'hapticsEnabled': hapticsEnabled,
      'localeCode': localeCode,
    };
  }

  factory PreferencesState.fromJson(Map<String, dynamic> json) {
    return PreferencesState(
      autoServerSwitch: json['autoServerSwitch'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      localeCode: json['localeCode'] as String?,
    );
  }

  @override
  List<Object?> get props => [autoServerSwitch, hapticsEnabled, localeCode];
}
