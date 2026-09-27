import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modèle représentant une chanson
/// À REMPLACER plus tard par votre modèle généré depuis Swagger
class Song {
  final String id;
  final String title;
  final String artist;
  final String imageUrl;
  final String audioUrl;
  final Duration duration;
  final String? lyrics; // Les paroles (peut être null si pas encore chargées)

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.audioUrl,
    required this.duration,
    this.lyrics,
  });
}

/// État global du lecteur audio
class PlayerState {
  final Song? currentSong;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isRepeat;
  final bool isShuffle;
  final bool isLiked;
  final bool isLoadingLyrics;

  const PlayerState({
    this.currentSong,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isRepeat = false,
    this.isShuffle = false,
    this.isLiked = false,
    this.isLoadingLyrics = false,
  });

  PlayerState copyWith({
    Song? currentSong,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? isRepeat,
    bool? isShuffle,
    bool? isLiked,
    bool? isLoadingLyrics,
  }) {
    return PlayerState(
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isRepeat: isRepeat ?? this.isRepeat,
      isShuffle: isShuffle ?? this.isShuffle,
      isLiked: isLiked ?? this.isLiked,
      isLoadingLyrics: isLoadingLyrics ?? this.isLoadingLyrics,
    );
  }
}

/// Notifier pour gérer le lecteur audio
class PlayerNotifier extends Notifier<PlayerState> {
  @override
  PlayerState build() {
    return const PlayerState();
  }

  /// Démarrer une nouvelle chanson
  Future<void> playSong(Song song, {bool autoPlay = true}) async {
    state = state.copyWith(
      currentSong: song,
      duration: song.duration,
      position: Duration.zero,
      isPlaying: autoPlay,
      isLoadingLyrics: true,
    );

    // TODO: Intégrer votre lecteur audio réel (just_audio, audioplayers, etc.)
    // TODO: Charger les paroles depuis votre API Swagger
    
    // Simulation : chargement des paroles
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(isLoadingLyrics: false);
  }

  void togglePlayPause() {
    state = state.copyWith(isPlaying: !state.isPlaying);
    // TODO: Appeler votre service audio : pause() ou play()
  }

  void seek(Duration position) {
    state = state.copyWith(position: position);
    // TODO: Appeler votre service audio : seek(position)
  }

  void toggleLike() {
    state = state.copyWith(isLiked: !state.isLiked);
  }

  void toggleRepeat() {
    state = state.copyWith(isRepeat: !state.isRepeat);
  }

  void toggleShuffle() {
    state = state.copyWith(isShuffle: !state.isShuffle);
  }

  void next() {
    // TODO: Passer à la chanson suivante depuis la playlist
  }

  void previous() {
    // TODO: Revenir à la chanson précédente
  }

  void stop() {
    state = const PlayerState();
  }
}

/// Provider global du lecteur
final playerProvider = NotifierProvider<PlayerNotifier, PlayerState>(() {
  return PlayerNotifier();
});

/// Provider dérivé : la chanson actuelle (pratique pour le MiniPlayer)
final currentSongProvider = Provider<Song?>((ref) {
  return ref.watch(playerProvider).currentSong;
});

/// Provider dérivé : est-ce qu'une chanson est en cours de lecture
final isPlayingProvider = Provider<bool>((ref) {
  return ref.watch(playerProvider).isPlaying;
});