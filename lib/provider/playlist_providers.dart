import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:titan_tunes/data/datasources/playlist_datasource.dart';
import 'package:titan_tunes/data/repositories/playlist_repository_impl.dart';
import 'package:titan_tunes/domaine/repositories/playlist_repository.dart';
import 'package:titan_tunes/provider/auth_provider.dart'
  show dioProvider, connectivityServiceProvider;

final playlistRemoteDatasourceProvider =
    Provider<PlaylistRemoteDataSource>((ref) {
  return PlaylistRemoteDataSourceImpl(
    dio: ref.watch(dioProvider),
    connectivity: ref.watch(connectivityServiceProvider),
  );
});

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  return PlaylistRepositoryImpl(
    remote: ref.watch(playlistRemoteDatasourceProvider),
  );
});