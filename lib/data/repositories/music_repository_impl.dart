import 'package:titan_tunes/core/exceptions.dart/exceptions.dart';
import 'package:titan_tunes/core/exceptions.dart/failures.dart';
import 'package:titan_tunes/data/datasources/music_remote_datasource.dart';
import 'package:titan_tunes/data/mappers/album_mapper.dart';
import 'package:titan_tunes/data/mappers/song_mapper.dart';
import 'package:titan_tunes/domaine/entities/album_entity.dart';
import 'package:titan_tunes/domaine/entities/song_entity.dart';
import 'package:titan_tunes/domaine/repositories/music_repository.dart';

class MusicRepositoryImpl implements MusicRepository {
  final MusicRemoteDataSource _remoteDataSource;

  MusicRepositoryImpl({required MusicRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<AlbumEntity>> getAllAlbums() async {
    try {
      final models = await _remoteDataSource.getAllAlbums();
      return models.map((m) => m.toEntity()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (_) {
      throw const UnexpectedFailure();
    }
  }
 /*
  @override
Future<List<SongEntity>> getSongsByArtist(String artistId) async {
  try {
    final models = await _remoteDataSource.getSongsByArtist(artistId);
    return models.map((m) => m.toEntity()).toList();
  } on ServerException catch (e) {
    throw ServerFailure(e.message);
  } on NetworkException catch (e) {
    throw NetworkFailure(e.message);
  }
}
*/
  @override
  Future<List<SongEntity>> getAllSongs() async {
    try {
      final models = await _remoteDataSource.getAllSongs();
      return models.map((m) => m.toEntity()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (_) {
      throw const UnexpectedFailure();
    }
  }
}