import 'package:titan_tunes/domaine/entities/favorite_entity.dart';

abstract class FavoriteRepository {
  /// Ajoute un favori
  Future<void> addFavorite(FavoriteEntity favorite);

  /// Supprime un favori
  Future<void> removeFavorite(FavoriteEntity favorite);

  /// (Optionnel) Récupère tous les IDs de chansons aimées d'un client
  Future<List<String>> getFavoriteSongIds(String clientTrackingId);
}