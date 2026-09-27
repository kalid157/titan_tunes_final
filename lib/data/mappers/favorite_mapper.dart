import 'package:titan_tunes/data/models/favorite_model.dart';
import 'package:titan_tunes/domaine/entities/favorite_entity.dart';

extension FavoriteEntityMapper on FavoriteEntity {
  FavoriteModel toModel() => FavoriteModel(
        clientTrackingId: clientTrackingId,
        songTrackingId: songTrackingId,
      );
}

extension FavoriteModelMapper on FavoriteModel {
  FavoriteEntity toEntity() => FavoriteEntity(
        clientTrackingId: clientTrackingId,
        songTrackingId: songTrackingId,
      );
}