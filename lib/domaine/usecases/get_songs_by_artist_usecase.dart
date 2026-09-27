import 'package:titan_tunes/domaine/repositories/music_repository.dart';

class GetSongsByArtistUseCase {
  final MusicRepository _repository;
  GetSongsByArtistUseCase(this._repository);

  //Future<List<SongEntity>> call(String artistId) =>_repository.getSongsByArtist(artistId);
}