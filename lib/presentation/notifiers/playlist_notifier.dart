import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:titan_tunes/core/exceptions.dart/failures.dart';
import 'package:titan_tunes/domaine/entities/playlist_entity.dart';
import 'package:titan_tunes/provider/playlist_providers.dart';

enum MusicTab { music, podcasts }
enum MusicSubTab { playlists, artists, albums }

class PlaylistState {
  final List<PlaylistEntity> playlists;       // depuis /playlist/all
  final List<PlaylistEntity> albumPlaylists;  // depuis /albums/all
  final MusicTab mainTab;
  final MusicSubTab subTab;
  final bool isLoading;
  final String? error;

  const PlaylistState({
    this.playlists = const [],
    this.albumPlaylists = const [],
    this.mainTab = MusicTab.music,
    this.subTab = MusicSubTab.playlists,
    this.isLoading = false,
    this.error,
  });

  ///  Items affichés selon le sous-onglet
  List<PlaylistEntity> get displayedItems {
    switch (subTab) {
      case MusicSubTab.playlists:
        return playlists;
      case MusicSubTab.albums:
        return albumPlaylists;
      case MusicSubTab.artists:
        // Regroupe par artiste unique
        final Map<String, PlaylistEntity> artists = {};
        for (final album in albumPlaylists) {
          final artistName = album.subtitle ?? 'Inconnu';
          artists.putIfAbsent(
            artistName,
            () => PlaylistEntity(
              id: 'artist_$artistName',
              title: artistName,
              subtitle: 'Artiste',
              imageUrl: album.imageUrl,
              type: PlaylistType.artist,
            ),
          );
        }
        return artists.values.toList();
    }
  }

  PlaylistState copyWith({
    List<PlaylistEntity>? playlists,
    List<PlaylistEntity>? albumPlaylists,
    MusicTab? mainTab,
    MusicSubTab? subTab,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      PlaylistState(
        playlists: playlists ?? this.playlists,
        albumPlaylists: albumPlaylists ?? this.albumPlaylists,
        mainTab: mainTab ?? this.mainTab,
        subTab: subTab ?? this.subTab,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

class PlaylistNotifier extends Notifier<PlaylistState> {
  @override
  PlaylistState build() => const PlaylistState();

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Charge les 2 en parallèle
      final results = await Future.wait([
        ref.read(playlistRepositoryProvider).getAllPlaylists(),
        ref.read(playlistRepositoryProvider).getAllAlbumsAsPlaylists(),
      ]);

      state = PlaylistState(
        playlists: results[0],
        albumPlaylists: results[1],
      );
    } on Failure catch (f) {
      state = state.copyWith(isLoading: false, error: f.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur de chargement des playlists',
      );
    }
  }

  void setMainTab(MusicTab tab) {
    state = state.copyWith(mainTab: tab);
  }

  void setSubTab(MusicSubTab tab) {
    state = state.copyWith(subTab: tab);
  }

  // ⭐ Créer une nouvelle playlist
Future<bool> createPlaylist({
  required String titre,
  required String clientTrackingId,
  String? imageUrl,
}) async {
  state = state.copyWith(isLoading: true, clearError: true);
  try {
    final playlist = await ref.read(playlistRepositoryProvider).createPlaylist(
          titre: titre,
          clientTrackingId: clientTrackingId,
          imageUrl: imageUrl,
        );

    // Ajoute à la liste locale
    final updated = [playlist, ...state.playlists];
    state = PlaylistState(
      playlists: updated,
      albumPlaylists: state.albumPlaylists,
      mainTab: state.mainTab,
      subTab: state.subTab,
    );
    return true;
  } on Failure catch (f) {
    state = state.copyWith(isLoading: false, error: f.message);
    return false;
  } catch (_) {
    state = state.copyWith(
      isLoading: false,
      error: 'Erreur de création',
    );
    return false;
  }
}

// ⭐ Ajouter une song à une playlist
Future<bool> addSongToPlaylist({
  required String playlistId,
  required String songId,
}) async {
  try {
    await ref.read(playlistRepositoryProvider).addSongToPlaylist(
          trackingIdSong: songId,
          trackingIdPlaylist: playlistId,
        );
    return true;
  } on Failure catch (f) {
    state = state.copyWith(error: f.message);
    return false;
  } catch (_) {
    state = state.copyWith(error: 'Erreur lors de l\'ajout');
    return false;
  }
}
}

final playlistNotifierProvider = NotifierProvider<PlaylistNotifier, PlaylistState>(() => PlaylistNotifier());