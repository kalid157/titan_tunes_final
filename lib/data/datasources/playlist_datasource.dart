import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:titan_tunes/config/service/app_endpoint.dart';
import 'package:titan_tunes/config/service/connectivity_service.dart';
import 'package:titan_tunes/core/exceptions.dart/exceptions.dart';
import 'package:titan_tunes/data/models/playlist_model.dart';
import 'package:titan_tunes/data/models/song_model.dart';

abstract class PlaylistRemoteDataSource {
  Future<List<PlaylistModel>> getAllPlaylists();
  Future<List<PlaylistModel>> getAllAlbumsAsPlaylists();

  Future<PlaylistModel> createPlaylist({
    required String titre,
    required String clientTrackingId,
    String? imageUrl,
  });

  Future<void> addSongToPlaylist({
    required String trackingIdSong,
    required String trackingIdPlaylist,
  });

  Future<List<SongModel>> getPlaylistSongs(String playlistId);
}

class PlaylistRemoteDataSourceImpl implements PlaylistRemoteDataSource {
  final Dio _dio;
  final ConnectivityService _conn;

  PlaylistRemoteDataSourceImpl({
    required Dio dio,
    required ConnectivityService connectivity,
  })  : _dio = dio,
        _conn = connectivity;

@override
Future<PlaylistModel> createPlaylist({
  required String titre,
  required String clientTrackingId,
  String? imageUrl,
}) async {
  if (!await _conn.hasConnection()) throw const NetworkException();

  try {
    debugPrint('🎵 POST ${AppEndpoint.addPlaylist}');
    debugPrint('🎵 Body: {titre: $titre, clientTrackingId: $clientTrackingId}');

    final res = await _dio.post(
      AppEndpoint.addPlaylist,
      data: {
        'titre': titre,
        'clientTrackingId': clientTrackingId,
        if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      },
    );

    debugPrint('✅ Playlist créée: ${res.data}');

    // Le backend peut renvoyer la playlist créée ou juste un 201
    if (res.data is Map<String, dynamic>) {
      return PlaylistModel.fromJson(res.data as Map<String, dynamic>);
    }

    // Fallback
    return PlaylistModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: titre,
      imageUrl: imageUrl,
      type: 'custom',
    );
  } on DioException catch (e) {
    debugPrint('❌ Erreur createPlaylist: ${e.response?.statusCode}');
    debugPrint('❌ Body: ${e.response?.data}');
    throw ServerException(
      message: 'Impossible de créer la playlist',
      statusCode: e.response?.statusCode,
    );
  }
}

@override
Future<void> addSongToPlaylist({
  required String trackingIdSong,
  required String trackingIdPlaylist,
}) async {
  if (!await _conn.hasConnection()) throw const NetworkException();

  try {
    debugPrint('🎵 POST ${AppEndpoint.addSongToPlaylist}');
    debugPrint('🎵 Body: {trackingIdSong: $trackingIdSong, '
        'trackingIdPlaylist: $trackingIdPlaylist}');

    final res = await _dio.post(
      AppEndpoint.addSongToPlaylist,
      data: {
        'trackingIdSong': trackingIdSong,
        'trackingIdPlaylist': trackingIdPlaylist,
      },
    );

    debugPrint('✅ Song ajoutée: ${res.statusCode}');
  } on DioException catch (e) {
    debugPrint('❌ Erreur addSongToPlaylist: ${e.response?.statusCode}');
    debugPrint('❌ Body: ${e.response?.data}');
    throw ServerException(
      message: 'Impossible d\'ajouter la chanson',
      statusCode: e.response?.statusCode,
    );
  }
}

@override
Future<List<SongModel>> getPlaylistSongs(String playlistId) async {
  if (!await _conn.hasConnection()) throw const NetworkException();

  try {
    final res = await _dio.get(AppEndpoint.playlistSongs(playlistId));
    final data = res.data;
    final List<dynamic> list = _extractList(data);

    return list
        .whereType<Map<String, dynamic>>()
        .map(SongModel.fromJson)
        .toList();
  } on DioException catch (e) {
    // Si l'endpoint n'existe pas encore → renvoie une liste vide
    if (e.response?.statusCode == 404) return [];
    throw ServerException(
      message: 'Erreur serveur',
      statusCode: e.response?.statusCode,
    );
  }
}
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

  ///  Extrait une liste depuis différentes structures de réponse
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