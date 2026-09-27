import 'package:titan_tunes/core/exceptions.dart/exceptions.dart';
import 'package:titan_tunes/core/exceptions.dart/failures.dart';
import 'package:titan_tunes/data/datasources/favorite_remote_datasource.dart';
import 'package:titan_tunes/data/mappers/favorite_mapper.dart';
import 'package:titan_tunes/domaine/entities/favorite_entity.dart';
import 'package:titan_tunes/domaine/repositories/favorite_repository.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteRemoteDataSource _remoteDataSource;

  FavoriteRepositoryImpl({required FavoriteRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<void> addFavorite(FavoriteEntity favorite) async {
    try {
      await _remoteDataSource.addFavorite(favorite.toModel());
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (_) {
      throw const UnexpectedFailure();
    }
  }

  @override
  Future<void> removeFavorite(FavoriteEntity favorite) async {
    try {
      await _remoteDataSource.removeFavorite(favorite.toModel());
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (_) {
      throw const UnexpectedFailure();
    }
  }

  @override
  Future<List<String>> getFavoriteSongIds(String clientTrackingId) async {
    try {
      return await _remoteDataSource.getFavoriteSongIds(clientTrackingId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (_) {
      throw const UnexpectedFailure();
    }
  }
}