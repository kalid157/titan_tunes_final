import 'package:dio/dio.dart';
import 'package:titan_tunes/config/service/app_endpoint.dart';
import 'package:titan_tunes/config/service/connectivity_service.dart';
import 'package:titan_tunes/core/exceptions.dart/exceptions.dart';
import 'package:titan_tunes/data/models/album_model.dart';
import 'package:titan_tunes/data/models/song_model.dart';

abstract class MusicRemoteDataSource {
  Future<List<AlbumModel>> getAllAlbums();
  Future<List<SongModel>> getAllSongs();
 // Future<List<SongModel>> getSongsByArtist(String artistId);
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
    return _getList<AlbumModel>(
      path: AppEndpoint.allAlbums,
      parser: (json) => AlbumModel.fromJson(json),
    );
  }

  //pour récupérer les chansons d'un artiste spécifique
/*@override
Future<List<SongModel>> getSongsByArtist(String artistId) async {
  if (!await _connectivity.hasConnection()) {
    throw const NetworkException();
  }

  try {
    final response = await _dio.get(AppEndpoint.songsByArtist(artistId));
    final data = response.data;
    final List<dynamic> list = data is List
        ? data
        : (data is Map && data['data'] is List)
            ? data['data'] as List
            : [];

    return list
        .whereType<Map<String, dynamic>>()
        .map(SongModel.fromJson)
        .toList();
  } on DioException catch (e) {
    throw ServerException(
      message: 'Erreur (${e.response?.statusCode})',
      statusCode: e.response?.statusCode,
    );
  }
}
*/
  @override
  Future<List<SongModel>> getAllSongs() async {
    return _getList<SongModel>(
      path: AppEndpoint.allSongs,
      parser: (json) => SongModel.fromJson(json),
    );
  }

  /// Méthode générique pour éviter la duplication
  Future<List<T>> _getList<T>({
    required String path,
    required T Function(Map<String, dynamic>) parser,
  }) async {
    if (!await _connectivity.hasConnection()) {
      throw const NetworkException();
    }

    try {
      final response = await _dio.get(path);
      final data = response.data;

      // Le backend peut renvoyer soit une List directe, soit { data: [...] }
      List<dynamic> rawList;
      if (data is List) {
        rawList = data;
      } else if (data is Map && data['data'] is List) {
        rawList = data['data'] as List;
      } else {
        throw const ParsingException();
      }

      return rawList
          .whereType<Map<String, dynamic>>()
          .map(parser)
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on FormatException {
      throw const ParsingException();
    } catch (_) {
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