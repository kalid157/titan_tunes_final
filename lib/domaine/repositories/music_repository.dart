import 'package:titan_tunes/domaine/entities/album_entity.dart';
import 'package:titan_tunes/domaine/entities/song_entity.dart';

abstract class MusicRepository {
  Future<List<AlbumEntity>> getAllAlbums();
  Future<List<SongEntity>> getAllSongs();
  Future<List<SongEntity>> getSongsByAlbum(String albumId);
}