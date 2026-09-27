import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:titan_tunes/config/service/app_endpoint.dart';
import 'package:titan_tunes/config/service/connectivity_service.dart';
import 'package:titan_tunes/core/exceptions.dart/exceptions.dart';
import 'package:titan_tunes/data/models/playlist_model.dart';

abstract class PlaylistRemoteDataSource {
  Future<List<PlaylistModel>> getAllPlaylists();
  Future<List<PlaylistModel>> getAllAlbumsAsPlaylists();
}

class PlaylistRemoteDataSourceImpl implements PlaylistRemoteDataSource {
  final Dio _dio;
  final ConnectivityService _conn;

  PlaylistRemoteDataSourceImpl({
    required Dio dio,
    required ConnectivityService connectivity,
  })  : _dio = dio,
        _conn = connectivity;

  // ══════════════════════════════════════════════════════════
  // PLAYLISTS (depuis /playlist/all)
  // ══════════════════════════════════════════════════════════
  @override
  Future<List<PlaylistModel>> getAllPlaylists() async {
    if (!await _conn.hasConnection()) {
      throw const NetworkException();
    }

    try {
      debugPrint('🎵 GET ${AppEndpoint.allPlaylists}');
      final res = await _dio.get(AppEndpoint.allPlaylists);
      final data = res.data;

      debugPrint('🎵 Status: ${res.statusCode}');
      debugPrint('🎵 Response: $data');

      //  Gère plusieurs formats de réponse :
      // 1. List directe : [...]
      // 2. Objet avec data : { data: [...] }
      // 3. Objet avec playlists : { playlists: [...] }
      final List<dynamic> list = _extractList(data);

      return list
          .whereType<Map<String, dynamic>>()
          .map(PlaylistModel.fromJson)
          .toList();
    } on DioException catch (e) {
      debugPrint('❌ /playlist/all : ${e.response?.statusCode}');
      debugPrint('❌ Body: ${e.response?.data}');
      throw ServerException(
        message: 'Erreur serveur (${e.response?.statusCode})',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Parse error: $e');
      throw const ParsingException();
    }
  }

  // ══════════════════════════════════════════════════════════
  // ALBUMS (depuis /albums/all) - utilisé dans l'onglet Álbumes
  // ══════════════════════════════════════════════════════════
  @override
  Future<List<PlaylistModel>> getAllAlbumsAsPlaylists() async {
    if (!await _conn.hasConnection()) {
      throw const NetworkException();
    }

    try {
      final res = await _dio.get(AppEndpoint.allAlbums);
      final data = res.data;
      final List<dynamic> list = _extractList(data);

      return list
          .whereType<Map<String, dynamic>>()
          .map(PlaylistModel.fromAlbumJson)
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: 'Erreur serveur (${e.response?.statusCode})',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// ⭐ Extrait une liste depuis différentes structures de réponse
  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      // Essaie plusieurs clés communes
      for (final key in ['data', 'playlists', 'content', 'items', 'results']) {
        if (data[key] is List) return data[key] as List;
      }
    }
    return [];
  }
}