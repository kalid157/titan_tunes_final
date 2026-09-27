import 'package:titan_tunes/domaine/entities/register_entity.dart';
import 'package:titan_tunes/domaine/entities/user_entity.dart';

/// Contrat du repository Register (couche DOMAIN).
abstract class RegisterRepository {
  /// Inscrit un nouvel utilisateur.
  /// Retourne l'utilisateur créé, ou lance une Failure.
  Future<UserEntity> register(RegisterEntity entity);
}