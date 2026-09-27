/// Failures exposées à la couche Domain/UI.
/// Elles représentent une erreur *métier* compréhensible par l'utilisateur.
library;

/// Classe de base abstraite pour toutes les failures
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

/// Le serveur a renvoyé une erreur
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Une erreur serveur est survenue']);
}

/// Pas de connexion internet
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Vérifiez votre connexion internet']);
}

/// Authentification échouée (401, mauvais mot de passe, etc.)
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Email ou mot de passe incorrect']);
}

/// Validation des données échouée (côté client)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Erreur liée au cache local
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erreur de cache local']);
}

/// Erreur inattendue (fallback)
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Une erreur inattendue est survenue']);
}