/// Entité Album (couche DOMAIN).
class AlbumEntity {
  final String trackingId;
  final String titreAlbum;
  final String nomArtiste;
  final String imageAlbum;

  const AlbumEntity({
    required this.trackingId,
    required this.titreAlbum,
    required this.nomArtiste,
    required this.imageAlbum,
  });

  @override
  String toString() => 'AlbumEntity($titreAlbum - $nomArtiste)';
}