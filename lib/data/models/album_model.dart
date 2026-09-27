//import 'package:titan_tunes/domain/entities/album_entity.dart'; // pour AlbumEntity

/// Modèle Album — reflète le JSON de GET /albums/all
class AlbumModel {
  final String trackingId;
  final String titreAlbum;
  final String nomArtiste;
  final String imageAlbum;

  const AlbumModel({
    required this.trackingId,
    required this.titreAlbum,
    required this.nomArtiste,
    required this.imageAlbum,
  });

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      trackingId: json['trackingId'] as String? ?? '',
      titreAlbum: json['titreAlbum'] as String? ?? '',
      nomArtiste: json['nomArtiste'] as String? ?? '',
      imageAlbum: json['imageAlbum'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'trackingId': trackingId,
        'titreAlbum': titreAlbum,
        'nomArtiste': nomArtiste,
        'imageAlbum': imageAlbum,
      };
}