import 'package:titan_tunes/core/exceptions.dart/failures.dart';
import 'package:titan_tunes/domaine/entities/favorite_entity.dart';
import 'package:titan_tunes/domaine/repositories/favorite_repository.dart';

class AddFavoriteUseCase {
  final FavoriteRepository _repository;
  AddFavoriteUseCase(this._repository);

  Future<void> call({
    required String clientTrackingId,
    required String songTrackingId,
  }) {
    if (clientTrackingId.isEmpty) {
      throw const ValidationFailure('Utilisateur non connecté');
    }
    if (songTrackingId.isEmpty) {
      throw const ValidationFailure('Chanson invalide');
    }
    return _repository.addFavorite(FavoriteEntity(
      clientTrackingId: clientTrackingId,
      songTrackingId: songTrackingId,
    ));
  }
}