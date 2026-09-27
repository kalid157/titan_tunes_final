/// Modèle Song — reflète le JSON de GET /song/getAll
class SongModel {
  final String trackingId;
  final String titre;
  final String audio;
  final String artiste;
  final bool isVip;

  const SongModel({
    required this.trackingId,
    required this.titre,
    required this.audio,
    required this.artiste,
    this.isVip = false,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      trackingId: json['trackingId'] as String? ?? '',
      titre: json['titre'] as String? ?? '',
      audio: json['audio'] as String? ?? '',
      artiste: json['artiste'] as String? ?? '',
      isVip: json['isVip'] as bool? ?? json['vip'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'trackingId': trackingId,
        'titre': titre,
        'audio': audio,
        'artiste': artiste,
      };
}