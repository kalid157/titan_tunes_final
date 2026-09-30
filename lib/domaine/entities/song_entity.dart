/// Entité Song (couche DOMAIN).
class SongEntity {
  final String trackingId;
  final String titre;
  final String audio;
  final String artiste;

  final String? artisteTrackingId;
  final String? albumTrackingId;
  final String? categorieTrackingId;

  /// ⭐ Chanson VIP : verrouillée pour les non-premium
  final bool isVip;

  const SongEntity({
    required this.trackingId,
    required this.titre,
    required this.audio,
    required this.artiste,
    this.artisteTrackingId,
    this.albumTrackingId,
    this.categorieTrackingId,
    this.isVip = false,
  });

  @override
  String toString() => 'SongEntity($titre — album: $albumTrackingId)';
}