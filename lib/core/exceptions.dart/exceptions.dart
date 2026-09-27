/// Exceptions lancées par la couche DATA.
/// Elles sont ensuite converties en Failures dans le Repository.
library;

/// Erreur renvoyée par le serveur (HTTP 4xx / 5xx)
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Pas de connexion internet
class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Pas de connexion internet']);

  @override
  String toString() => 'NetworkException: $message';
}

/// Non authentifié (401)
class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException([this.message = 'Identifiants invalides']);

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Erreur lors du parsing du JSON
class ParsingException implements Exception {
  final String message;
  const ParsingException([this.message = 'Erreur de lecture des données']);

  @override
  String toString() => 'ParsingException: $message';
}

/// Erreur de cache local (SharedPreferences, Hive, ...)
class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Erreur de cache local']);

  @override
  String toString() => 'CacheException: $message';
}