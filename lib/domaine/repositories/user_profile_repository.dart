import 'package:titan_tunes/domaine/entities/user_profile_entity.dart';

abstract class UserProfileRepository {
  /// Retourne null si le backend n'a pas encore l'endpoint
  Future<UserProfileEntity?> getProfile(String clientId);
  Future<void> updatePlan(String clientId, SubscriptionPlan plan);
}