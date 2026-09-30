import 'package:titan_tunes/domaine/entities/album_entity.dart';

class AlbumModel {
  final String trackingId;
  final String titreAlbum;
  final String nomArtiste;
  final String imageAlbum;
  final bool isVip;
  final bool isNew;

  const AlbumModel({
    required this.trackingId,
    required this.titreAlbum,
    required this.nomArtiste,
    required this.imageAlbum,
    this.isVip = false,
    this.isNew = false,
  });

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      trackingId: json['trackingId'] as String? ?? '',
      titreAlbum: json['titreAlbum'] as String? ?? '',
      nomArtiste: json['nomArtiste'] as String? ?? '',
      imageAlbum: json['imageAlbum'] as String? ?? '',
      isVip: json['isVip'] as bool? ?? json['vip'] as bool? ?? false,
      isNew: json['isNew'] as bool? ?? json['nouveau'] as bool? ?? false,
    );
  }

  AlbumModel copyWith({bool? isVip, bool? isNew}) => AlbumModel(
        trackingId: trackingId,
        titreAlbum: titreAlbum,
        nomArtiste: nomArtiste,
        imageAlbum: imageAlbum,
        isVip: isVip ?? this.isVip,
        isNew: isNew ?? this.isNew,
      );

  Map<String, dynamic> toJson() => {
        'trackingId': trackingId,
        'titreAlbum': titreAlbum,
        'nomArtiste': nomArtiste,
        'imageAlbum': imageAlbum,
        'isVip': isVip,
        'isNew': isNew,
      };
}