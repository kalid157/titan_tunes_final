import 'package:titan_tunes/data/models/user_profile_model.dart';
import 'package:titan_tunes/domaine/entities/user_profile_entity.dart';

extension UserProfileModelMapper on UserProfileModel {
  UserProfileEntity toEntity() => UserProfileEntity(
        trackingId: trackingId,
        email: email,
        firstName: firstName ?? '',
        lastName: lastName ?? '',
        phone: phone,
        avatarUrl: avatarUrl,
        plan: isPremium
            ? SubscriptionPlan.premiumIndividual
            : SubscriptionPlan.free,
        monthlyPrice: monthlyPrice,
      );
}

extension UserProfileEntityMapper on UserProfileEntity {
  UserProfileModel toModel() => UserProfileModel(
        trackingId: trackingId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        avatarUrl: avatarUrl,
        isPremium: isPremium,
        monthlyPrice: monthlyPrice,
      );
}