import 'package:titan_tunes/domaine/repositories/favorite_repository.dart';

class GetFavoriteSongIdsUseCase {
  final FavoriteRepository _repository;
  GetFavoriteSongIdsUseCase(this._repository);

  Future<List<String>> call(String clientTrackingId) {
    return _repository.getFavoriteSongIds(clientTrackingId);
  }
}