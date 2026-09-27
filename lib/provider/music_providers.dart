import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:titan_tunes/data/datasources/music_remote_datasource.dart';
import 'package:titan_tunes/data/repositories/music_repository_impl.dart';
import 'package:titan_tunes/domaine/repositories/music_repository.dart';
import 'package:titan_tunes/domaine/usecases/get_all_albums_usecase.dart';
import 'package:titan_tunes/domaine/usecases/get_all_songs_usecase.dart';
import 'package:titan_tunes/presentation/notifiers/music_notifier.dart';
import 'package:titan_tunes/provider/auth_provider.dart';

    //show dioProvider, connectivityServiceProvider;

// --- Data ---
final musicRemoteDataSourceProvider = Provider<MusicRemoteDataSource>((ref) {
  return MusicRemoteDataSourceImpl(
    dio: ref.watch(dioProvider),
    connectivity: ref.watch(connectivityServiceProvider),
  );
});

final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  return MusicRepositoryImpl(
    remoteDataSource: ref.watch(musicRemoteDataSourceProvider),
  );
});

// --- Domain ---
final getAllAlbumsUseCaseProvider = Provider<GetAllAlbumsUseCase>((ref) {
  return GetAllAlbumsUseCase(ref.watch(musicRepositoryProvider));
});

final getAllSongsUseCaseProvider = Provider<GetAllSongsUseCase>((ref) {
  return GetAllSongsUseCase(ref.watch(musicRepositoryProvider));
});

/*
final getSongsByArtistUseCaseProvider = Provider<GetSongsByArtistUseCase>((ref) {
  return GetSongsByArtistUseCase(ref.watch(musicRepositoryProvider));
});
*/
// --- Presentation ---
final musicNotifierProvider =
    NotifierProvider<MusicNotifier, MusicState>(() => MusicNotifier());