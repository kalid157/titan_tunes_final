import 'package:titan_tunes/domaine/entities/playlist_entity.dart';
import 'package:titan_tunes/domaine/entities/song_entity.dart';

abstract class PlaylistRepository {
  Future<List<PlaylistEntity>> getAllPlaylists();
  Future<List<PlaylistEntity>> getAllAlbumsAsPlaylists();

  Future<PlaylistEntity> createPlaylist({
    required String titre,
    required String clientTrackingId,
    String? imageUrl,
  });

  Future<void> addSongToPlaylist({
    required String trackingIdSong,
    required String trackingIdPlaylist,
  });

  Future<List<SongEntity>> getPlaylistSongs(String playlistId);
}