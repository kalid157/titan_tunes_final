import 'package:titan_tunes/core/exceptions.dart/failures.dart';
import 'package:titan_tunes/domaine/entities/user_entity.dart';
import 'package:titan_tunes/domaine/repositories/auth_repository.dart';

/// UseCase : connexion utilisateur.
/// 
/// Responsabilités :
///   - Valider les données (email, password)
///   - Appeler le Repository
///   - Lever une [Failure] en cas d'erreur
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<UserEntity> call({
    required String email,
    required String password,
  }) async {
    // --- Validations côté client ---
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw const ValidationFailure('Email et mot de passe requis');
    }
    if (!_isValidEmail(email)) {
      throw const ValidationFailure('Format d\'email invalide');
    }
    if (password.length < 6) {
      throw const ValidationFailure(
        'Le mot de passe doit contenir au moins 6 caractères',
      );
    }

    // --- Appel du Repository ---
    return _repository.login(
      email: email.trim(),
      password: password.trim(),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$')
        .hasMatch(email.trim());
  }
}