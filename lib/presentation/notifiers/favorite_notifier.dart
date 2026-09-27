import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan_tunes/core/exceptions.dart/failures.dart';
import 'package:titan_tunes/presentation/notifiers/like_count_notifier.dart';
import 'package:titan_tunes/provider/favorite_providers.dart'
    show getFavoriteSongIdsUseCaseProvider,
         addFavoriteUseCaseProvider,
         removeFavoriteUseCaseProvider;

class FavoriteState {
  final Set<String> likedSongIds;
  final bool isLoading;
  final String? errorMessage;

  const FavoriteState({
    this.likedSongIds = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  bool isLiked(String songTrackingId) => likedSongIds.contains(songTrackingId);

  FavoriteState copyWith({
    Set<String>? likedSongIds,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FavoriteState(
      likedSongIds: likedSongIds ?? this.likedSongIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class FavoriteNotifier extends Notifier<FavoriteState> {
  static const _prefsKey = 'favorite_song_ids';

  @override
  FavoriteState build() {
    _loadFromLocal();
    return const FavoriteState();
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_prefsKey);
      if (json != null) {
        final List<dynamic> list = jsonDecode(json);
        state = state.copyWith(
          likedSongIds: list.map((e) => e.toString()).toSet(),
        );
      }
    } catch (_) {}
  }

  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode(state.likedSongIds.toList()),
      );
    } catch (_) {}
  }

  Future<void> loadFavorites(String clientTrackingId) async {
    if (clientTrackingId.isEmpty) return;
    try {
      final ids = await ref.read(getFavoriteSongIdsUseCaseProvider)(
        clientTrackingId,
      );
      final merged = {...state.likedSongIds, ...ids};
      state = state.copyWith(likedSongIds: merged);
      await _saveToLocal();
    } catch (_) {}
  }

  /// Toggle like avec mise à jour du compteur
  Future<void> toggleFavorite({
    required String clientTrackingId,
    required String songTrackingId,
  }) async {
    if (clientTrackingId.isEmpty || songTrackingId.isEmpty) return;

    final wasLiked = state.isLiked(songTrackingId);

    // 1. Mise à jour optimiste locale
    final newSet = Set<String>.from(state.likedSongIds);
    if (wasLiked) {
      newSet.remove(songTrackingId);
    } else {
      newSet.add(songTrackingId);
    }
    state = state.copyWith(likedSongIds: newSet, clearError: true);

    // 2. Mise à jour du compteur
    if (wasLiked) {
      ref.read(likeCountProvider.notifier).decrement(songTrackingId);
    } else {
      ref.read(likeCountProvider.notifier).increment(songTrackingId);
    }

    // 3. Sauvegarde locale
    await _saveToLocal();

    // 4. Sync API en arrière-plan
    try {
      if (wasLiked) {
        await ref.read(removeFavoriteUseCaseProvider)(
          clientTrackingId: clientTrackingId,
          songTrackingId: songTrackingId,
        );
      } else {
        await ref.read(addFavoriteUseCaseProvider)(
          clientTrackingId: clientTrackingId,
          songTrackingId: songTrackingId,
        );
      }
    } on Failure catch (f) {
      state = state.copyWith(errorMessage: f.message);
    } catch (_) {
      state = state.copyWith(errorMessage: 'Sync favoris en attente');
    }
  }

  Future<void> clear() async {
    state = const FavoriteState();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}

///  SOURCE UNIQUE du provider favoriteNotifierProvider
final favoriteNotifierProvider =
    NotifierProvider<FavoriteNotifier, FavoriteState>(() => FavoriteNotifier());