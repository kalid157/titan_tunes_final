
class UserProfileModel {
  final String trackingId;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? avatarUrl;
  final bool isPremium;
  final double monthlyPrice;

  const UserProfileModel({
    required this.trackingId,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.avatarUrl,
    this.isPremium = false,
    this.monthlyPrice = 0.0,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) => UserProfileModel(
        trackingId: (json['trackingId'] ?? json['id'] ?? '').toString(),
        email: json['email'] as String? ?? '',
        firstName: json['firstName'] as String?,
        lastName: json['lastName'] as String?,
        phone: json['phone'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        isPremium: json['isPremium'] as bool? ?? false,
        monthlyPrice: (json['monthlyPrice'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'trackingId': trackingId,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'isPremium': isPremium,
        'monthlyPrice': monthlyPrice,
      };
}