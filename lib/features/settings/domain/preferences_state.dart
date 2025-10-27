import 'package:equatable/equatable.dart';

class PreferencesState extends Equatable {
  static const Object _sentinel = Object();

  const PreferencesState({
    this.autoServerSwitch = true,
    this.hapticsEnabled = true,
    this.localeCode,
    this.privacyPolicyAccepted = false,
    this.onboardingCompleted = false,
    this.autoReconnect = false,
  });

  final bool autoServerSwitch;
  final bool hapticsEnabled;
  final String? localeCode;
  final bool privacyPolicyAccepted;
  final bool onboardingCompleted;
  final bool autoReconnect;

  PreferencesState copyWith({
    bool? autoServerSwitch,
    bool? hapticsEnabled,
    Object? localeCode = _sentinel,
    bool? privacyPolicyAccepted,
    bool? onboardingCompleted,
    bool? autoReconnect,
  }) {
    return PreferencesState(
      autoServerSwitch: autoServerSwitch ?? this.autoServerSwitch,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      localeCode:
          identical(localeCode, _sentinel) ? this.localeCode : localeCode as String?,
      privacyPolicyAccepted: privacyPolicyAccepted ?? this.privacyPolicyAccepted,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      autoReconnect: autoReconnect ?? this.autoReconnect,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoServerSwitch': autoServerSwitch,
      'hapticsEnabled': hapticsEnabled,
      'localeCode': localeCode,
      'privacyPolicyAccepted': privacyPolicyAccepted,
      'onboardingCompleted': onboardingCompleted,
      'autoReconnect': autoReconnect,
    };
  }

  factory PreferencesState.fromJson(Map<String, dynamic> json) {
    return PreferencesState(
      autoServerSwitch: json['autoServerSwitch'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      localeCode: json['localeCode'] as String?,
      privacyPolicyAccepted: json['privacyPolicyAccepted'] as bool? ?? false,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      autoReconnect: json['autoReconnect'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        autoServerSwitch,
        hapticsEnabled,
        localeCode,
        privacyPolicyAccepted,
        onboardingCompleted,
        autoReconnect,
      ];
}
