import 'package:titan_tunes/data/models/playlist_model.dart';
import 'package:titan_tunes/domaine/entities/playlist_entity.dart';

extension PlaylistModelMapper on PlaylistModel {
  PlaylistEntity toEntity() {
    PlaylistType t;
    switch (type) {
      case 'liked':
        t = PlaylistType.liked;
        break;
      case 'album':
        t = PlaylistType.album;
        break;
      case 'artist':
        t = PlaylistType.artist;
        break;
      case 'radio':
        t = PlaylistType.radio;
        break;
      default:
        t = PlaylistType.custom;
    }

    return PlaylistEntity(
      id: id,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      songCount: songCount,
      type: t,
    );
  }
}