import 'package:titan_tunes/domaine/entities/playlist_entity.dart';

abstract class PlaylistRepository {
  Future<List<PlaylistEntity>> getAllPlaylists();
  Future<List<PlaylistEntity>> getAllAlbumsAsPlaylists();
}