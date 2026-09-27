/// Entité Song (couche DOMAIN).
class SongEntity {
  final String trackingId;
  final String titre;
  final String audio;    // URL du fichier MP3
  final String artiste;
  final bool isVip; 
  const SongEntity({
    required this.trackingId,
    required this.titre,
    required this.audio,
    required this.artiste,
    this.isVip = false,
  });

  @override
  String toString() => 'SongEntity($titre - $artiste)';
}