/// Entité Favorite (couche DOMAIN).
/// Représente la relation entre un client et une chanson aimée.
class FavoriteEntity {
  final String clientTrackingId;
  final String songTrackingId;

  const FavoriteEntity({
    required this.clientTrackingId,
    required this.songTrackingId,
  });
}