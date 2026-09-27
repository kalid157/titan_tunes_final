import 'package:dio/dio.dart';
import 'package:titan_tunes/config/service/app_endpoint.dart';
import 'package:titan_tunes/config/service/connectivity_service.dart';
import 'package:titan_tunes/core/exceptions.dart/exceptions.dart';
import 'package:titan_tunes/data/models/register_model.dart';
import 'package:titan_tunes/data/models/user_model.dart';

/// Contrat du DataSource Register distant.
abstract class RegisterRemoteDataSource {
  Future<UserModel> register(RegisterModel model);
}

/// Implémentation concrète via Dio.
class RegisterRemoteDataSourceImpl implements RegisterRemoteDataSource {
  final Dio _dio;
  final ConnectivityService _connectivity;

  RegisterRemoteDataSourceImpl({
    required Dio dio,
    required ConnectivityService connectivity,
  })  : _dio = dio,
        _connectivity = connectivity;

  @override
  Future<UserModel> register(RegisterModel model) async {
    // 1. Vérifier la connexion
    if (!await _connectivity.hasConnection()) {
      throw const NetworkException();
    }

    try {
      // 2. Requête POST
      final response = await _dio.post(
        AppEndpoint.register,
        data: model.toJson(),
      );

      // 3. Analyser la réponse (200 ou 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // Cas 1 : le backend renvoie l'user directement
        if (data is Map<String, dynamic>) {
          final userJson = data['user'] is Map<String, dynamic>
              ? data['user'] as Map<String, dynamic>
              : data;
          return UserModel.fromJson(userJson);
        }

        // Cas 2 : le backend ne renvoie rien → on construit un UserModel à partir des infos connues
        return UserModel(
          id: '',
          email: model.email,
          username: '${model.firstName} ${model.lastName}',
        );
      }

      throw ServerException(
        message: 'Réponse inattendue du serveur',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on FormatException {
      throw const ParsingException();
    } catch (_) {
      throw const ServerException(message: 'Erreur inconnue');
    }
  }

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
        if (status == 409) return ServerException(
              message: 'Cet email est déjà utilisé',
              statusCode: status,
            );
        return ServerException(message: message, statusCode: status);

      default:
        return const ServerException(message: 'Erreur réseau');
    }
  }
}