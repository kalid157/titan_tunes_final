import 'package:titan_tunes/domaine/entities/album_entity.dart';
import 'package:titan_tunes/domaine/repositories/music_repository.dart';

class GetAllAlbumsUseCase {
  final MusicRepository _repository;
  GetAllAlbumsUseCase(this._repository);

  Future<List<AlbumEntity>> call() => _repository.getAllAlbums();
}