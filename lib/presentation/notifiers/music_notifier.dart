import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:titan_tunes/core/exceptions.dart/failures.dart';
import 'package:titan_tunes/domaine/entities/album_entity.dart';
import 'package:titan_tunes/domaine/entities/song_entity.dart';
import 'package:titan_tunes/provider/music_providers.dart';

class MusicState {
  final List<AlbumEntity> albums;
  final List<SongEntity> allSongs;    // toutes les chansons (pour la playlist home)
  final bool isLoading;
  final String? errorMessage;

  const MusicState({
    this.albums = const [],
    this.allSongs = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  MusicState copyWith({
    List<AlbumEntity>? albums,
    List<SongEntity>? allSongs,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MusicState(
      albums: albums ?? this.albums,
      allSongs: allSongs ?? this.allSongs,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class MusicNotifier extends Notifier<MusicState> {
  @override
  MusicState build() => const MusicState();

  /// Charge albums + songs en parallèle
  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        ref.read(getAllAlbumsUseCaseProvider)(),
        ref.read(getAllSongsUseCaseProvider)(),
      ]);

      final albums = results[0] as List<AlbumEntity>;
      final songs = results[1] as List<SongEntity>;

      state = MusicState(albums: albums, allSongs: songs);
    } on Failure catch (f) {
      state = state.copyWith(isLoading: false, errorMessage: f.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur de chargement',
      );
    }
  }

  /// Retourne les chansons d'un album (filtre par nom d'artiste car l'API songs
  /// ne fournit pas de albumId direct — adapte si tu as un vrai champ)
  List<SongEntity> songsOfAlbum(AlbumEntity album) {
    return state.allSongs
        .where((s) => s.artiste.toLowerCase() == album.nomArtiste.toLowerCase())
        .toList();
  }
}