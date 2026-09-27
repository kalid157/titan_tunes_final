/// Type d'une playlist (utilisé pour l'icône)
enum PlaylistType { custom, liked, album, artist, radio, curated }

class PlaylistEntity {
  final String id;
  final String title;
  final String? subtitle;      // "de Spotify", "de Lauramart", etc.
  final String? imageUrl;      // Image de couverture
  final int? songCount;        // "120 canciones"
  final PlaylistType type;

  const PlaylistEntity({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.songCount,
    this.type = PlaylistType.custom,
  });
}