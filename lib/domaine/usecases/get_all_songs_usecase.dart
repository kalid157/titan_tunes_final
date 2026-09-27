import 'package:titan_tunes/domaine/entities/song_entity.dart';
import 'package:titan_tunes/domaine/repositories/music_repository.dart';

class GetAllSongsUseCase {
  final MusicRepository _repository;
  GetAllSongsUseCase(this._repository);

  Future<List<SongEntity>> call() => _repository.getAllSongs();
}