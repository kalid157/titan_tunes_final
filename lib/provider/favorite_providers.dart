import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:titan_tunes/data/datasources/favorite_remote_datasource.dart';
import 'package:titan_tunes/data/repositories/favorite_repository_impl.dart';

import 'package:titan_tunes/domaine/repositories/favorite_repository.dart';
import 'package:titan_tunes/domaine/usecases/add_favorite_usecase.dart';
import 'package:titan_tunes/domaine/usecases/get_favorite_song_ids_usecase.dart';
import 'package:titan_tunes/domaine/usecases/remove_favorite_usecase.dart';
import 'package:titan_tunes/provider/auth_provider.dart'show dioProvider, connectivityServiceProvider;
//import 'package:titan_tunes/presentation/provider/auth_providers.dart'
   // show dioProvider, connectivityServiceProvider;

// ⭐ RÉ-EXPORT : rend `favoriteNotifierProvider`, `FavoriteNotifier` et
// `FavoriteState` accessibles à tous ceux qui importent ce fichier.
// Sans redéfinir le provider (source unique = favorite_notifier.dart).
export 'package:titan_tunes/presentation/notifiers/favorite_notifier.dart'
    show favoriteNotifierProvider, FavoriteNotifier, FavoriteState;

// --- Data ---
final favoriteRemoteDataSourceProvider =
    Provider<FavoriteRemoteDataSource>((ref) {
  return FavoriteRemoteDataSourceImpl(
    dio: ref.watch(dioProvider),
    connectivity: ref.watch(connectivityServiceProvider),
  );
});

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepositoryImpl(
    remoteDataSource: ref.watch(favoriteRemoteDataSourceProvider),
  );
});

// --- Domain (Use Cases) ---
final addFavoriteUseCaseProvider = Provider<AddFavoriteUseCase>((ref) {
  return AddFavoriteUseCase(ref.watch(favoriteRepositoryProvider));
});

final removeFavoriteUseCaseProvider = Provider<RemoveFavoriteUseCase>((ref) {
  return RemoveFavoriteUseCase(ref.watch(favoriteRepositoryProvider));
});

final getFavoriteSongIdsUseCaseProvider =
    Provider<GetFavoriteSongIdsUseCase>((ref) {
  return GetFavoriteSongIdsUseCase(ref.watch(favoriteRepositoryProvider));
});