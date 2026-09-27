import 'package:titan_tunes/data/models/song_model.dart';
import 'package:titan_tunes/domaine/entities/song_entity.dart';

extension SongModelMapper on SongModel {
  SongEntity toEntity() => SongEntity(
        trackingId: trackingId,
        titre: titre,
        audio: audio,
        artiste: artiste,
      );
}

extension SongEntityMapper on SongEntity {
  SongModel toModel() => SongModel(
        trackingId: trackingId,
        titre: titre,
        audio: audio,
        artiste: artiste,
      );
}