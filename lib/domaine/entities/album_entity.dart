/// Entité Album (couche DOMAIN).
class AlbumEntity {
  final String trackingId;
  final String titreAlbum;
  final String nomArtiste;
  final String imageAlbum;

  /// ⭐ Album Premium : verrouillé pour les non-premium
  final bool isVip;

  /// ⭐ Nouvel album : verrouillé par défaut (dernier album mis à jour)
  final bool isNew;

  const AlbumEntity({
    required this.trackingId,
    required this.titreAlbum,
    required this.nomArtiste,
    required this.imageAlbum,
    this.isVip = false,
    this.isNew = false,
  });

  /// ⭐ Un album est verrouillé s'il est VIP ou Nouveau
  bool get isLocked => isVip || isNew;

  AlbumEntity copyWith({
    String? trackingId,
    String? titreAlbum,
    String? nomArtiste,
    String? imageAlbum,
    bool? isVip,
    bool? isNew,
  }) {
    return AlbumEntity(
      trackingId: trackingId ?? this.trackingId,
      titreAlbum: titreAlbum ?? this.titreAlbum,
      nomArtiste: nomArtiste ?? this.nomArtiste,
      imageAlbum: imageAlbum ?? this.imageAlbum,
      isVip: isVip ?? this.isVip,
      isNew: isNew ?? this.isNew,
    );
  }

  @override
  String toString() =>
      'AlbumEntity($titreAlbum — ${isLocked ? "🔒" : "🔓"})';
}