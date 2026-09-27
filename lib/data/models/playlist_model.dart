class PlaylistModel {
  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final int? songCount;
  final String type;

  const PlaylistModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.songCount,
    this.type = 'custom',
  });

  /// ⭐ Depuis l'API `/playlist/all`
  /// Gère plusieurs formats possibles côté backend.
  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      // ID : trackingId, id, _id, playlistId
      id: (json['trackingId'] ??
              json['id'] ??
              json['_id'] ??
              json['playlistId'] ??
              '')
          .toString(),

      // Titre : plusieurs clés possibles
      title: (json['titre'] ??
              json['title'] ??
              json['name'] ??
              json['nom'] ??
              'Sans titre')
          .toString(),

      // Sous-titre (artiste, propriétaire, description)
      subtitle: (json['artiste'] ??
              json['artist'] ??
              json['owner'] ??
              json['description'] ??
              json['auteur'])
          ?.toString(),

      // Image de couverture
      imageUrl: (json['imageUrl'] ??
              json['image'] ??
              json['cover'] ??
              json['imageAlbum'] ??
              json['thumbnail'])
          ?.toString(),

      // Nombre de chansons
      songCount: json['songCount'] as int? ??
          json['nombreChansons'] as int? ??
          json['count'] as int? ??
          json['totalSongs'] as int?,

      // Type : custom, liked, album, artist, radio, curated
      type: (json['type'] ?? json['playlistType'] ?? 'custom').toString(),
    );
  }

  /// Depuis un album `/albums/all`
  factory PlaylistModel.fromAlbumJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: (json['trackingId'] ?? '').toString(),
      title: json['titreAlbum'] as String? ?? '',
      subtitle: json['nomArtiste'] as String? ?? '',
      imageUrl: json['imageAlbum'] as String?,
      type: 'album',
    );
  }

  Map<String, dynamic> toJson() => {
        'trackingId': id,
        'titre': title,
        'artiste': subtitle,
        'imageUrl': imageUrl,
        'songCount': songCount,
        'type': type,
      };
}