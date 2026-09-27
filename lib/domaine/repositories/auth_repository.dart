import 'package:titan_tunes/domaine/entities/user_entity.dart';

/// Contrat du repository Auth (couche DOMAIN).
/// 
/// Le Domain définit CE QU'ON VEUT faire (login, register...).
/// La Data décidera COMMENT (Dio, Firebase, mock...).
abstract class AuthRepository {
  /// Connecte un utilisateur avec email + password
  /// 
  /// Lance une [Failure] si l'opération échoue.
  Future<UserEntity> login({
    required String email,
    required String password,
  });

  /// Déconnecte l'utilisateur
  Future<void> logout();
}