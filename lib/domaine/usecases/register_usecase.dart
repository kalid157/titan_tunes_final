import 'package:titan_tunes/core/exceptions.dart/failures.dart';
import 'package:titan_tunes/domaine/entities/register_entity.dart';
import 'package:titan_tunes/domaine/entities/user_entity.dart';
import 'package:titan_tunes/domaine/repositories/register_repository.dart';

class RegisterUseCase {
  final RegisterRepository _repository;

  RegisterUseCase(this._repository);

  Future<UserEntity> call({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
  }) async {
    // --- Validations ---
    if (firstName.trim().isEmpty) {
      throw const ValidationFailure('Le prénom est requis');
    }
    if (lastName.trim().isEmpty) {
      throw const ValidationFailure('Le nom est requis');
    }
    if (!_isValidEmail(email)) {
      throw const ValidationFailure('Format d\'email invalide');
    }
    if (password.length < 6) {
      throw const ValidationFailure(
        'Le mot de passe doit contenir au moins 6 caractères',
      );
    }
    if (!_isValidPhone(phone)) {
      throw const ValidationFailure('Numéro de téléphone invalide');
    }

    // --- Construction de l'entité ---
    final entity = RegisterEntity(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim(),
      password: password.trim(),
      phone: phone.trim(),
    );

    return _repository.register(entity);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$')
        .hasMatch(email.trim());
  }

  bool _isValidPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    return digits.length >= 8 && digits.length <= 15;
  }
}