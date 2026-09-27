import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:titan_tunes/config/service/app_endpoint.dart';
import 'package:titan_tunes/config/service/connectivity_service.dart';
import 'package:titan_tunes/core/exceptions.dart/exceptions.dart';
import 'package:titan_tunes/data/models/favorite_model.dart';

abstract class FavoriteRemoteDataSource {
  Future<void> addFavorite(FavoriteModel model);
  Future<void> removeFavorite(FavoriteModel model);
  Future<List<String>> getFavoriteSongIds(String clientTrackingId);
}

class FavoriteRemoteDataSourceImpl implements FavoriteRemoteDataSource {
  final Dio _dio;
  final ConnectivityService _connectivity;

  FavoriteRemoteDataSourceImpl({
    required Dio dio,
    required ConnectivityService connectivity,
  })  : _dio = dio,
        _connectivity = connectivity;

  // ══════════════════════════════════════════════════════════
  // ADD FAVORITE
  // ══════════════════════════════════════════════════════════
  @override
  Future<void> addFavorite(FavoriteModel model) async {
    if (!await _connectivity.hasConnection()) {
      throw const NetworkException();
    }

    debugPrint('🎯 POST ${AppEndpoint.favoris}');
    debugPrint('🎯 Body: ${model.toJson()}');

    try {
      final response = await _dio.post(
        AppEndpoint.favoris,
        data: model.toJson(),
      );
      debugPrint('✅ POST /favoris OK: ${response.statusCode}');
      debugPrint('✅ Response: ${response.data}');
    } on DioException catch (e) {
      debugPrint('❌ POST /favoris : ${e.type}');
      debugPrint('❌ Status: ${e.response?.statusCode}');
      debugPrint('❌ Body: ${e.response?.data}');
      throw _handleDioError(e);
    }
  }

  // ══════════════════════════════════════════════════════════
  // REMOVE FAVORITE
  // ══════════════════════════════════════════════════════════
  @override
  Future<void> removeFavorite(FavoriteModel model) async {
    if (!await _connectivity.hasConnection()) {
      throw const NetworkException();
    }

    debugPrint('🎯 DELETE ${AppEndpoint.favoris}');
    debugPrint('🎯 Body: ${model.toJson()}');

    try {
      // ⚠️ Essaie d'abord avec body (comme ton POST).
      // Si ça échoue, on passera aux query params.
      final response = await _dio.delete(
        AppEndpoint.favoris,
        data: model.toJson(),
      );

      debugPrint('✅ DELETE /favoris OK: ${response.statusCode}');

      if (response.statusCode != 200 &&
          response.statusCode != 204) {
        throw ServerException(
          message: 'Impossible de retirer le favori',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ DELETE /favoris : ${e.type}');
      debugPrint('❌ Status: ${e.response?.statusCode}');
      debugPrint('❌ Body: ${e.response?.data}');
      throw _handleDioError(e);
    }
  }

  // ══════════════════════════════════════════════════════════
  // GET FAVORITE SONG IDS
  // ══════════════════════════════════════════════════════════
  @override
  Future<List<String>> getFavoriteSongIds(String clientTrackingId) async {
    if (!await _connectivity.hasConnection()) {
      throw const NetworkException();
    }

    try {
      final response = await _dio.get(
        '${AppEndpoint.favoris}/$clientTrackingId',
      );

      final data = response.data;
      final List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List;
      } else {
        return [];
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((e) =>
              e['SongTrackingId'] as String? ??
              e['songTrackingId'] as String? ??
              '')
          .where((id) => id.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      // ⚠️ Si l'endpoint GET n'existe pas, on retourne une liste vide
      // au lieu de crasher tout le chargement
      debugPrint('❌ GET /favoris/$clientTrackingId : ${e.response?.statusCode}');
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw _handleDioError(e);
    }
  }

  // ══════════════════════════════════════════════════════════
  // ERROR HANDLER
  // ══════════════════════════════════════════════════════════
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkException('Délai de connexion dépassé');
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        return ServerException(
          message: 'Erreur serveur (${e.response?.statusCode})',
          statusCode: e.response?.statusCode,
        );
      default:
        return const ServerException(message: 'Erreur réseau');
    }
  }
}