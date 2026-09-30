class SongModel {
  final String trackingId;
  final String titre;
  final String audio;
  final String artiste;
  final String? artisteTrackingId;
  final String? albumTrackingId;
  final String? categorieTrackingId;
  final bool isVip;

  const SongModel({
    required this.trackingId,
    required this.titre,
    required this.audio,
    required this.artiste,
    this.artisteTrackingId,
    this.albumTrackingId,
    this.categorieTrackingId,
    this.isVip = false,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      trackingId: json['trackingId'] as String? ?? '',
      titre: json['titre'] as String? ?? '',
      audio: json['audio'] as String? ?? '',
      artiste: json['artiste'] as String? ?? '',
      artisteTrackingId: json['artisteTrackingId'] as String?,
      albumTrackingId: json['albumTrackingId'] as String?,
      categorieTrackingId: json['categorieTrackingId'] as String?,
      isVip: json['isVip'] as bool? ?? json['vip'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'trackingId': trackingId,
        'titre': titre,
        'audio': audio,
        'artiste': artiste,
        if (artisteTrackingId != null) 'artisteTrackingId': artisteTrackingId,
        if (albumTrackingId != null) 'albumTrackingId': albumTrackingId,
        if (categorieTrackingId != null)
          'categorieTrackingId': categorieTrackingId,
        'isVip': isVip,
      };
}