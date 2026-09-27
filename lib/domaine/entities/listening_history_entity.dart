class ListeningHistoryEntity {
  final String songId;
  final String songTitle;
  final String artist;
  final String? albumImageUrl;
  final DateTime listenedAt;

  const ListeningHistoryEntity({
    required this.songId,
    required this.songTitle,
    required this.artist,
    this.albumImageUrl,
    required this.listenedAt,
  });

  Map<String, dynamic> toJson() => {
        'songId': songId,
        'songTitle': songTitle,
        'artist': artist,
        'albumImageUrl': albumImageUrl,
        'listenedAt': listenedAt.toIso8601String(),
      };

  factory ListeningHistoryEntity.fromJson(Map<String, dynamic> json) =>
      ListeningHistoryEntity(
        songId: json['songId'] as String? ?? '',
        songTitle: json['songTitle'] as String? ?? '',
        artist: json['artist'] as String? ?? '',
        albumImageUrl: json['albumImageUrl'] as String?,
        listenedAt:
            DateTime.tryParse(json['listenedAt'] as String? ?? '') ?? DateTime.now(),
      );
}