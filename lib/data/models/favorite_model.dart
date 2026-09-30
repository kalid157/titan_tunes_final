/// Modèle Favorite — reflète le JSON envoyé à POST/DELETE /favoris
class FavoriteModel {
  final String clientTrackingId;
  final String songTrackingId;

  const FavoriteModel({
    required this.clientTrackingId,
    required this.songTrackingId,
  });

  
  ///  schéma du backend :
  Map<String, dynamic> toJson() => {
        'ClientTrackingId': clientTrackingId,
        'SongTrackingId': songTrackingId,
      };

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      clientTrackingId: json['ClientTrackingId'] as String? ??
          json['clientTrackingId'] as String? ??
          '',
      songTrackingId: json['SongTrackingId'] as String? ??
          json['songTrackingId'] as String? ??
          '',
    );
  }
}