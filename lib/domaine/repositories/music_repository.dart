import 'package:titan_tunes/domaine/entities/album_entity.dart';
import 'package:titan_tunes/domaine/entities/song_entity.dart';

abstract class MusicRepository {
  /// Récupère tous les albums
  Future<List<AlbumEntity>> getAllAlbums();

  /// Récupère toutes les chansons
  Future<List<SongEntity>> getAllSongs();
  /// Récupère les chansons d'un artiste spécifique
  //Future<List<SongEntity>> getSongsByArtist(String artistId);
}