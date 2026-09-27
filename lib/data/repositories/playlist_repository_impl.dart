import 'package:titan_tunes/core/exceptions.dart/exceptions.dart';
import 'package:titan_tunes/core/exceptions.dart/failures.dart';
import 'package:titan_tunes/data/datasources/playlist_datasource.dart';
import 'package:titan_tunes/data/mappers/playlist_mapper.dart';
import 'package:titan_tunes/domaine/entities/playlist_entity.dart';
import 'package:titan_tunes/domaine/repositories/playlist_repository.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistRemoteDataSource _remote;

  PlaylistRepositoryImpl({required PlaylistRemoteDataSource remote})
      : _remote = remote;

  @override
  Future<List<PlaylistEntity>> getAllPlaylists() async {
    try {
      final models = await _remote.getAllPlaylists();
      return models.map((m) => m.toEntity()).toList();
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (_) {
      throw const UnexpectedFailure();
    }
  }

  @override
  Future<List<PlaylistEntity>> getAllAlbumsAsPlaylists() async {
    try {
      final models = await _remote.getAllAlbumsAsPlaylists();
      return models.map((m) => m.toEntity()).toList();
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (_) {
      throw const UnexpectedFailure();
    }
  }
}