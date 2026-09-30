import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:titan_tunes/config/service/app_endpoint.dart';
import 'package:titan_tunes/config/service/connectivity_service.dart';
import 'package:titan_tunes/core/exceptions.dart/exceptions.dart';
import 'package:titan_tunes/data/models/album_model.dart';
import 'package:titan_tunes/data/models/song_model.dart';

/// ⭐ Nombre d'albums récents à verrouiller
const int kLockedAlbumsCount = 2;

abstract class MusicRemoteDataSource {
  Future<List<AlbumModel>> getAllAlbums();
  Future<List<SongModel>> getAllSongs();
  Future<List<SongModel>> getSongsByAlbum(String albumId);
}

class MusicRemoteDataSourceImpl implements MusicRemoteDataSource {
  final Dio _dio;
  final ConnectivityService _connectivity;

  MusicRemoteDataSourceImpl({
    required Dio dio,
    required ConnectivityService connectivity,
  })  : _dio = dio,
        _connectivity = connectivity;

  @override
  Future<List<AlbumModel>> getAllAlbums() async {
    final list = await _getList<AlbumModel>(
      path: AppEndpoint.allAlbums,
      parser: (json) => AlbumModel.fromJson(json),
    );

    // ⭐ Marque les N premiers albums comme "nouveaux" (verrouillés)
    // Le backend peut aussi envoyer isNew / isVip directement
    return list.asMap().entries.map((entry) {
      final index = entry.key;
      final album = entry.value;

      // Déjà marqué par le backend ?
      if (album.isVip || album.isNew) return album;

      // Sinon, on considère les N premiers comme nouveaux
      if (index < kLockedAlbumsCount) {
        return album.copyWith(isNew: true);
      }
      return album;
    }).toList();
  }

  @override
  Future<List<SongModel>> getAllSongs() {
    return _getList<SongModel>(
      path: AppEndpoint.allSongs,
      parser: (json) => SongModel.fromJson(json),
    );
  }

  @override
  Future<List<SongModel>> getSongsByAlbum(String albumId) {
    return _getList<SongModel>(
      path: AppEndpoint.songsByAlbum(albumId),
      parser: (json) => SongModel.fromJson(json),
    );
  }

  Future<List<T>> _getList<T>({
    required String path,
    required T Function(Map<String, dynamic>) parser,
  }) async {
    if (!await _connectivity.hasConnection()) {
      throw const NetworkException();
    }

    try {
      debugPrint('🌐 GET $path');
      final response = await _dio.get(path);
      final data = response.data;

      List<dynamic> rawList;
      if (data is List) {
        rawList = data;
      } else if (data is Map && data['data'] is List) {
        rawList = data['data'] as List;
      } else {
        throw const ParsingException();
      }

      final result = rawList
          .whereType<Map<String, dynamic>>()
          .map(parser)
          .toList();

      debugPrint('✅ $path → ${result.length} items');
      return result;
    } on DioException catch (e) {
      debugPrint('❌ $path : ${e.response?.statusCode}');
      throw _handleDioError(e);
    } on FormatException {
      throw const ParsingException();
    } catch (e) {
      debugPrint('❌ Parse error: $e');
      throw const ServerException(message: 'Erreur de chargement');
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
        return ServerException(
          message: 'Erreur serveur (${e.response?.statusCode})',
          statusCode: e.response?.statusCode,
        );
      default:
        return const ServerException(message: 'Erreur réseau');
    }
  }
}