import 'package:dio/dio.dart';
import 'package:titan_tunes/config/service/app_endpoint.dart';
import 'package:titan_tunes/config/service/connectivity_service.dart';
import 'package:titan_tunes/core/exceptions.dart/exceptions.dart';
import 'package:titan_tunes/data/models/user_profile_model.dart';

abstract class UserProfileRemoteDataSource {
  /// Retourne null si l'endpoint backend n'existe pas encore (404/500)
  Future<UserProfileModel?> getProfile(String clientId);
}

class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final Dio _dio;
  final ConnectivityService _connectivity;

  UserProfileRemoteDataSourceImpl({
    required Dio dio,
    required ConnectivityService connectivity,
  })  : _dio = dio,
        _connectivity = connectivity;

  @override
  Future<UserProfileModel?> getProfile(String clientId) async {
    if (!await _connectivity.hasConnection()) {
      throw const NetworkException();
    }

    try {
      final res = await _dio.get(AppEndpoint.profile(clientId));
      return UserProfileModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final status = e.response?.statusCode;

      // ⭐ Endpoint pas encore implémenté côté backend
      // → on retourne null, le Notifier fera un fallback sur auth
      if (status == 404 ||
          status == 500 ||
          status == 501 ||
          status == 405) {
        return null;
      }

      if (status == 401) throw const UnauthorizedException();
      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException();
      }
      throw ServerException(
        message: 'Erreur serveur ($status)',
        statusCode: status,
      );
    }
  }
}