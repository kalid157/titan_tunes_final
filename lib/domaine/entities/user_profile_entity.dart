enum SubscriptionPlan { free, premiumIndividual, premiumFamily }

class UserProfileEntity {
  final String trackingId;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? avatarUrl;
  final SubscriptionPlan plan;
  final double monthlyPrice;
  final int publicPlaylists;
  final int following;

  const UserProfileEntity({
    required this.trackingId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.avatarUrl,
    this.plan = SubscriptionPlan.free,
    this.monthlyPrice = 0.0,
    this.publicPlaylists = 0,
    this.following = 0,
  });

  bool get isPremium => plan != SubscriptionPlan.free;

  String get fullName =>
      '$firstName $lastName'.trim().isEmpty ? email.split('@').first : '$firstName $lastName'.trim();

  String get planLabel => switch (plan) {
        SubscriptionPlan.free => 'Free',
        SubscriptionPlan.premiumIndividual => 'Premium - Individual',
        SubscriptionPlan.premiumFamily => 'Premium - Family',
      };

  UserProfileEntity copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    SubscriptionPlan? plan,
    double? monthlyPrice,
  }) =>
      UserProfileEntity(
        trackingId: trackingId,
        email: email ?? this.email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        phone: phone ?? this.phone,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        plan: plan ?? this.plan,
        monthlyPrice: monthlyPrice ?? this.monthlyPrice,
        publicPlaylists: publicPlaylists,
        following: following,
      );
}