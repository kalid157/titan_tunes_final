import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:titan_tunes/domaine/entities/album_entity.dart';
import 'package:titan_tunes/domaine/entities/song_entity.dart';
import 'package:titan_tunes/provider/music_providers.dart';

class ArtistState {
  final String? artistName;
  final String? artistImageUrl;
  final String? description;
  final List<AlbumEntity> albums;
  final List<SongEntity> allSongs;
  final AlbumEntity? selectedAlbum;

  /// ⭐ Songs de l'album sélectionné (chargées via /song/getByAlbum)
  final List<SongEntity> selectedAlbumSongs;

  final bool isLoading;
  final bool isLoadingAlbumSongs;

  const ArtistState({
    this.artistName,
    this.artistImageUrl,
    this.description,
    this.albums = const [],
    this.allSongs = const [],
    this.selectedAlbum,
    this.selectedAlbumSongs = const [],
    this.isLoading = false,
    this.isLoadingAlbumSongs = false,
  });

  /// ⭐ Songs à afficher :
  /// - Album sélectionné → ses songs (via /song/getByAlbum)
  /// - Sinon → toutes les songs de l'artiste
  List<SongEntity> get displayedSongs {
    if (selectedAlbum == null) return allSongs;
    return selectedAlbumSongs;
  }

  /// Nombre de songs dans un album donné (parmi les songs déjà chargées)
  int songsCountOf(AlbumEntity album) {
    return allSongs
        .where((s) => s.albumTrackingId == album.trackingId)
        .length;
  }

  bool get hasAlbumRelation =>
      allSongs.any((s) => s.albumTrackingId != null);

  List<AlbumEntity> visibleAlbums({required bool isPremium}) {
    if (isPremium) return albums;
    return albums.take(1).toList();
  }

  int get hiddenAlbumsCount => albums.length > 1 ? albums.length - 1 : 0;

  ArtistState copyWith({
    String? artistName,
    String? artistImageUrl,
    String? description,
    List<AlbumEntity>? albums,
    List<SongEntity>? allSongs,
    AlbumEntity? selectedAlbum,
    List<SongEntity>? selectedAlbumSongs,
    bool? isLoading,
    bool? isLoadingAlbumSongs,
    bool clearAlbum = false,
  }) {
    return ArtistState(
      artistName: artistName ?? this.artistName,
      artistImageUrl: artistImageUrl ?? this.artistImageUrl,
      description: description ?? this.description,
      albums: albums ?? this.albums,
      allSongs: allSongs ?? this.allSongs,
      selectedAlbum:
          clearAlbum ? null : (selectedAlbum ?? this.selectedAlbum),
      selectedAlbumSongs:
          clearAlbum ? const [] : (selectedAlbumSongs ?? this.selectedAlbumSongs),
      isLoading: isLoading ?? this.isLoading,
      isLoadingAlbumSongs:
          isLoadingAlbumSongs ?? this.isLoadingAlbumSongs,
    );
  }
}

class ArtistNotifier extends Notifier<ArtistState> {
  @override
  ArtistState build() => const ArtistState();

  /// Charge un artiste avec ses albums et ses songs
  Future<void> loadFromAlbum({
    required AlbumEntity tappedAlbum,
    required List<AlbumEntity> allAlbums,
    required List<SongEntity> allSongs,
  }) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 200));

    final artistName = tappedAlbum.nomArtiste.toLowerCase().trim();

    // Albums du même artiste
    final albumsOfArtist = allAlbums
        .where((a) => a.nomArtiste.toLowerCase().trim() == artistName)
        .toList();

    // Songs : via albumTrackingId en priorité
    final albumIds = albumsOfArtist.map((a) => a.trackingId).toSet();
    final songsByAlbumId = allSongs
        .where((s) =>
            s.albumTrackingId != null &&
            albumIds.contains(s.albumTrackingId))
        .toList();

    // Fallback
    final songs = songsByAlbumId.isNotEmpty
        ? songsByAlbumId
        : allSongs
            .where((s) => s.artiste.toLowerCase().trim() == artistName)
            .toList();

    debugPrint('📀 Albums: ${albumsOfArtist.length}');
    debugPrint('🎵 Songs: ${songs.length}');

    state = ArtistState(
      artistName: tappedAlbum.nomArtiste,
      artistImageUrl: tappedAlbum.imageAlbum,
      description:
          '${albumsOfArtist.length} album${albumsOfArtist.length > 1 ? "s" : ""}, '
          '${songs.length} chanson${songs.length > 1 ? "s" : ""}',
      albums: albumsOfArtist,
      allSongs: songs,
      selectedAlbum: null,
      selectedAlbumSongs: const [],
    );
  }

  /// ⭐ Sélectionne un album ET charge ses songs via l'API
  Future<void> selectAlbum(AlbumEntity album) async {
    state = state.copyWith(
      selectedAlbum: album,
      selectedAlbumSongs: const [],
      isLoadingAlbumSongs: true,
    );

    try {
      final songs = await ref
          .read(musicRepositoryProvider)
          .getSongsByAlbum(album.trackingId);

      state = state.copyWith(
        selectedAlbumSongs: songs,
        isLoadingAlbumSongs: false,
      );

      debugPrint('✅ ${songs.length} songs chargées pour "${album.titreAlbum}"');
    } catch (e) {
      debugPrint('❌ Erreur chargement album: $e');
      state = state.copyWith(
        isLoadingAlbumSongs: false,
        selectedAlbumSongs: const [],
      );
    }
  }

  void clearAlbumSelection() {
    state = state.copyWith(
      clearAlbum: true,
      selectedAlbumSongs: const [],
    );
  }

  void reset() {
    state = const ArtistState();
  }
}

final artistProvider = NotifierProvider<ArtistNotifier, ArtistState>(() {
  return ArtistNotifier();
});