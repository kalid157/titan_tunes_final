import 'package:dio/dio.dart';
import 'package:titan_tunes/config/service/app_endpoint.dart';
import 'package:titan_tunes/config/service/connectivity_service.dart';
import 'package:titan_tunes/core/exceptions.dart/exceptions.dart';
import 'package:titan_tunes/data/models/user_model.dart';

/// Contrat du DataSource Auth distant
abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
}

/// Implémentation concrète via Dio.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  final ConnectivityService _connectivity;

  AuthRemoteDataSourceImpl({
    required Dio dio,
    required ConnectivityService connectivity,
  })  : _dio = dio,
        _connectivity = connectivity;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // 1. Vérifier la connexion AVANT de lancer la requête
    if (!await _connectivity.hasConnection()) {
      throw const NetworkException();
    }

    try {
      // 2. Requête HTTP POST
      final response = await _dio.post(
        AppEndpoint.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      // 3. Analyser la réponse
      if (response.statusCode == 200 && response.data != null) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw ServerException(
        message: 'Réponse inattendue du serveur',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      // 4. Convertir les erreurs Dio en exceptions métier
      throw _handleDioError(e);
    } on FormatException {
      throw const ParsingException();
    } catch (_) {
      throw const ServerException(message: 'Erreur inconnue');
    }
  }

  /// Convertit une DioException en Exception métier
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkException('Délai de connexion dépassé');

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        final data = e.response?.data;
        String message = 'Erreur serveur';

        if (data is Map && data['message'] is String) {
          message = data['message'] as String;
        }

        if (status == 401) return UnauthorizedException(message);
        return ServerException(message: message, statusCode: status);

      case DioExceptionType.cancel:
        return const ServerException(message: 'Requête annulée');

      default:
        return const ServerException(message: 'Erreur réseau');
    }
  }
}