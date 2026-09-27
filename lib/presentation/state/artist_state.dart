import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:titan_tunes/domaine/entities/album_entity.dart';
import 'package:titan_tunes/domaine/entities/song_entity.dart';

class ArtistState {
  final String? artistName;
  final String? artistImageUrl;
  final String? description;
  final List<AlbumEntity> albums;
  final List<SongEntity> allSongs;
  final AlbumEntity? selectedAlbum;
  final bool isLoading;

  const ArtistState({
    this.artistName,
    this.artistImageUrl,
    this.description,
    this.albums = const [],
    this.allSongs = const [],
    this.selectedAlbum,
    this.isLoading = false,
  });

  ///  Songs affichées.
  /// 
  /// LIMITATION API : Pas d'albumId sur les songs.
  /// → On affiche TOUJOURS toutes les songs de l'artiste.
  /// 
  /// Quand le backend ajoutera `albumId` dans `/song/getAll` :
  ///   if (selectedAlbum == null) return allSongs;
  ///   return allSongs.where((s) => s.albumId == selectedAlbum!.trackingId).toList();
  List<SongEntity> get displayedSongs => allSongs;

  /// Albums visibles selon le plan
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
    bool? isLoading,
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
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ArtistNotifier extends Notifier<ArtistState> {
  @override
  ArtistState build() => const ArtistState();

  ///  Charge l'artiste en filtrant par nomArtiste/artiste
  /// (puisque c'est le seul champ commun entre albums et songs)
  Future<void> loadFromAlbum({
  required AlbumEntity tappedAlbum,
  required List<AlbumEntity> allAlbums,
  required List<SongEntity> allSongs,
}) async {
  //  Sécurité : reset avant de commencer
  state = state.copyWith(isLoading: true, clearAlbum: true);

  try {
    // Petit délai pour l'UX (évite le flash)
    await Future.delayed(const Duration(milliseconds: 200));

    final artistLower = tappedAlbum.nomArtiste.toLowerCase().trim();

    // Filtre albums
    final albumsOfArtist = allAlbums
        .where((a) => a.nomArtiste.toLowerCase().trim() == artistLower)
        .toList();

    // Filtre songs
    final songsOfArtist = allSongs
        .where((s) => s.artiste.toLowerCase().trim() == artistLower)
        .toList();

    //  Si rien n'a été trouvé, on met au moins l'album cliqué
    final safeAlbums =
        albumsOfArtist.isEmpty ? [tappedAlbum] : albumsOfArtist;

    state = ArtistState(
      artistName: tappedAlbum.nomArtiste,
      artistImageUrl: tappedAlbum.imageAlbum,
      description: 'Découvrez ${tappedAlbum.nomArtiste} : '
          '${safeAlbums.length} album${safeAlbums.length > 1 ? "s" : ""}, '
          '${songsOfArtist.length} chanson${songsOfArtist.length > 1 ? "s" : ""}.',
      albums: safeAlbums,
      allSongs: songsOfArtist,
      selectedAlbum: null,
      isLoading: false, //  Toujours false à la fin
    );
  } catch (e) {
    //  En cas d'erreur, on remplit avec les données minimum
    debugPrint('❌ loadFromAlbum error: $e');

    state = ArtistState(
      artistName: tappedAlbum.nomArtiste,
      artistImageUrl: tappedAlbum.imageAlbum,
      description: 'Artiste : ${tappedAlbum.nomArtiste}',
      albums: [tappedAlbum],
      allSongs: allSongs
          .where((s) =>
              s.artiste.toLowerCase() ==
              tappedAlbum.nomArtiste.toLowerCase())
          .toList(),
      selectedAlbum: null,
      isLoading: false, //  TOUJOURS reset
    );
  }
}

  void selectAlbum(AlbumEntity album) {
    state = state.copyWith(selectedAlbum: album);
  }

  void clearAlbumSelection() {
    state = state.copyWith(clearAlbum: true);
  }

  void reset() {
    state = const ArtistState();
  }
}

final artistProvider = NotifierProvider<ArtistNotifier, ArtistState>(() {
  return ArtistNotifier();
});