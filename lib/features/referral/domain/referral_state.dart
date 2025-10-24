import 'package:equatable/equatable.dart';

class ReferralState extends Equatable {
  const ReferralState({
    required this.referralCode,
    this.rewardsEarned = 0,
    this.referredUsers = const [],
  });

  final String referralCode;
  final int rewardsEarned;
  final List<String> referredUsers;

  ReferralState copyWith({
    String? referralCode,
    int? rewardsEarned,
    List<String>? referredUsers,
  }) {
    return ReferralState(
      referralCode: referralCode ?? this.referralCode,
      rewardsEarned: rewardsEarned ?? this.rewardsEarned,
      referredUsers: referredUsers ?? this.referredUsers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'referralCode': referralCode,
      'rewardsEarned': rewardsEarned,
      'referredUsers': referredUsers,
    };
  }

  factory ReferralState.fromJson(Map<String, dynamic> json) {
    return ReferralState(
      referralCode: json['referralCode'] as String? ?? '',
      rewardsEarned: json['rewardsEarned'] as int? ?? 0,
      referredUsers:
          ((json['referredUsers'] as List<dynamic>?) ?? const <dynamic>[])
              .map((e) => e as String)
              .toList(),
    );
  }

  @override
  List<Object?> get props => [referralCode, rewardsEarned, referredUsers];
}
