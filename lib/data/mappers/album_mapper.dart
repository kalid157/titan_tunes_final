import 'package:titan_tunes/data/models/album_model.dart';
import 'package:titan_tunes/domaine/entities/album_entity.dart';

extension AlbumModelMapper on AlbumModel {
  AlbumEntity toEntity() => AlbumEntity(
        trackingId: trackingId,
        titreAlbum: titreAlbum,
        nomArtiste: nomArtiste,
        imageAlbum: imageAlbum,
        isVip: isVip,
        isNew: isNew,
      );
}

extension AlbumEntityMapper on AlbumEntity {
  AlbumModel toModel() => AlbumModel(
        trackingId: trackingId,
        titreAlbum: titreAlbum,
        nomArtiste: nomArtiste,
        imageAlbum: imageAlbum,
        isVip: isVip,
        isNew: isNew,
      );
}