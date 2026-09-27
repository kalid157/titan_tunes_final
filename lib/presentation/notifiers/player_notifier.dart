import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:titan_tunes/domaine/entities/album_entity.dart';
import 'package:titan_tunes/domaine/entities/song_entity.dart';
import 'package:titan_tunes/presentation/notifiers/listening_history_notifier.dart';
import 'package:titan_tunes/provider/music_providers.dart';

/// Mode de répétition
enum RepeatMode { off, one, all }

class PlayerState {
  // ═══════════════════════════════════════════════════════════
  // ⭐ UI FOCUS — ce que l'utilisateur voit / interagit
  // ═══════════════════════════════════════════════════════════
  final SongEntity? currentSong;
  final AlbumEntity? currentAlbum;

  /// ⭐ Playlist affichée dans l'UI (celle de l'album en cours de vue)
  /// Peut être différente de la playlist audio si on prévisualise
  final List<SongEntity> uiPlaylist;

  // ═══════════════════════════════════════════════════════════
  // ⭐ AUDIO STATE — ce qui joue réellement dans just_audio
  // ═══════════════════════════════════════════════════════════
  final SongEntity? playingSong;
  final AlbumEntity? playingAlbum;

  /// ⭐ Playlist réellement chargée dans just_audio
  /// (utilisée pour l'auto-next et le previous/next)
  final List<SongEntity> audioPlaylist;

  final bool isPlaying;
  final Duration position;
  final Duration duration;

  // Modes
  final RepeatMode repeatMode;
  final bool shuffleEnabled;

  const PlayerState({
    this.currentSong,
    this.currentAlbum,
    this.uiPlaylist = const [],
    this.playingSong,
    this.playingAlbum,
    this.audioPlaylist = const [],
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.repeatMode = RepeatMode.off,
    this.shuffleEnabled = false,
  });

  /// True si le `currentSong` est bien celui qui joue
  bool isCurrentSong(SongEntity song) =>
      currentSong?.trackingId == song.trackingId;

  /// ⭐ True si l'UI affiche une chanson DIFFÉRENTE de celle qui joue
  bool get isPreviewOnly {
    if (currentSong == null) return false;
    if (playingSong == null) return true;
    return playingSong!.trackingId != currentSong!.trackingId;
  }

  /// ⭐ True si une musique joue en arrière-plan (même pendant une preview)
  bool get hasBackgroundAudio => playingSong != null && isPlaying;

  /// ⭐ Image de la chanson affichée dans l'UI
  String? get currentImageUrl => currentAlbum?.imageAlbum;

  /// ⭐ Image de la chanson qui joue réellement
  String? get playingImageUrl => playingAlbum?.imageAlbum;

  PlayerState copyWith({
    SongEntity? currentSong,
    AlbumEntity? currentAlbum,
    List<SongEntity>? uiPlaylist,
    SongEntity? playingSong,
    AlbumEntity? playingAlbum,
    List<SongEntity>? audioPlaylist,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    RepeatMode? repeatMode,
    bool? shuffleEnabled,
    bool clearAlbum = false,
    bool clearPlayingSong = false,
    bool clearPlayingAlbum = false,
  }) {
    return PlayerState(
      currentSong: currentSong ?? this.currentSong,
      currentAlbum: clearAlbum ? null : (currentAlbum ?? this.currentAlbum),
      uiPlaylist: uiPlaylist ?? this.uiPlaylist,
      playingSong: clearPlayingSong
          ? null
          : (playingSong ?? this.playingSong),
      playingAlbum: clearPlayingAlbum
          ? null
          : (playingAlbum ?? this.playingAlbum),
      audioPlaylist: audioPlaylist ?? this.audioPlaylist,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      repeatMode: repeatMode ?? this.repeatMode,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
    );
  }
}

class PlayerNotifier extends Notifier<PlayerState> {
  late final AudioPlayer _player;

  @override
  PlayerState build() {
    _player = AudioPlayer();

    // ⭐ Play/pause
    _player.playerStateStream.listen((s) {
      state = state.copyWith(isPlaying: s.playing);
    });

    // ⭐ Position
    _player.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });

    // ⭐ Durée
    _player.durationStream.listen((dur) {
      if (dur != null && dur > Duration.zero) {
        state = state.copyWith(duration: dur);
      }
    });

    // ⭐ Auto-next : utilise `audioPlaylist` (pas `uiPlaylist`)
    _player.currentIndexStream.listen((index) {
      if (index == null) return;
      if (index < 0 || index >= state.audioPlaylist.length) return;

      final newSong = state.audioPlaylist[index];
      final album = _resolveAlbum(newSong);

      state = state.copyWith(
        currentSong: newSong,
        currentAlbum: album,
        clearAlbum: album == null,
        uiPlaylist: state.audioPlaylist, // ⭐ synchronise l'UI
        playingSong: newSong,
        playingAlbum: album,
        clearPlayingAlbum: album == null,
        position: Duration.zero,
      );
    });

    // ⭐ Sync repeat/shuffle
    _player.loopModeStream.listen((loopMode) {
      final r = switch (loopMode) {
        LoopMode.off => RepeatMode.off,
        LoopMode.one => RepeatMode.one,
        LoopMode.all => RepeatMode.all,
      };
      state = state.copyWith(repeatMode: r);
    });

    _player.shuffleModeEnabledStream.listen((enabled) {
      state = state.copyWith(shuffleEnabled: enabled);
    });

    ref.onDispose(() => _player.dispose());

    return const PlayerState();
  }

  AlbumEntity? _resolveAlbum(SongEntity song) {
    try {
      final musicState = ref.read(musicNotifierProvider);
      return musicState.albums.firstWhere(
        (a) => a.nomArtiste.toLowerCase() == song.artiste.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // ⭐ PREVIEW — met à jour l'UI SANS toucher à l'audio
  // ═══════════════════════════════════════════════════════════
  void previewSong({
    required SongEntity song,
    List<SongEntity> playlist = const [],
    AlbumEntity? album,
  }) {
    final resolvedAlbum = album ?? _resolveAlbum(song);

    // ⚠️ On ne touche PAS à playingSong, playingAlbum, audioPlaylist,
    // isPlaying, position, duration → la musique continue
    state = state.copyWith(
      currentSong: song,
      currentAlbum: resolvedAlbum,
      clearAlbum: resolvedAlbum == null,
      // ⭐ Playlist UI = celle de l'album prévisualisé
      // (utilisée si l'utilisateur appuie sur play ensuite)
      uiPlaylist: playlist.isEmpty ? [song] : playlist,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ⭐ PLAY — joue réellement l'audio
  // ═══════════════════════════════════════════════════════════
  Future<void> playSongInPlaylist({
    required SongEntity song,
    required List<SongEntity> playlist,
    AlbumEntity? album,
  }) async {
    try {
      final index = playlist.indexWhere(
        (s) => s.trackingId == song.trackingId,
      );

      final resolvedAlbum = album ?? _resolveAlbum(song);

      // ⭐ Met à jour UI ET audio en même temps
      state = state.copyWith(
        // UI
        currentSong: song,
        currentAlbum: resolvedAlbum,
        clearAlbum: resolvedAlbum == null,
        uiPlaylist: playlist,
        // Audio
        playingSong: song,
        playingAlbum: resolvedAlbum,
        clearPlayingAlbum: resolvedAlbum == null,
        audioPlaylist: playlist,
        // Reset position
        position: Duration.zero,
      );

      final audioSources = playlist
          .map((s) => AudioSource.uri(Uri.parse(s.audio)))
          .toList();

      await _player.setAudioSources(
        audioSources,
        initialIndex: index < 0 ? 0 : index,
      );
      _player.play();

      ref.read(listeningHistoryProvider.notifier).record(
            song,
            albumImageUrl: resolvedAlbum?.imageAlbum,
          );
    } catch (e) {
      // ignore: avoid_print
      print('Erreur lecture: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // ⭐ Reset le focus sur la chanson qui joue réellement
  // ═══════════════════════════════════════════════════════════
  void focusOnPlayingSong() {
    if (state.playingSong == null) return;
    final album = _resolveAlbum(state.playingSong!);
    state = state.copyWith(
      currentSong: state.playingSong,
      currentAlbum: album,
      clearAlbum: album == null,
      uiPlaylist: state.audioPlaylist,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ⭐ Play/Pause intelligent
  // ═══════════════════════════════════════════════════════════
  void togglePlayPause() {
    // Cas 1 : En preview (une autre musique joue, ou rien ne joue)
    if (state.isPreviewOnly && state.currentSong != null) {
      final playlist = state.uiPlaylist;
      if (playlist.isEmpty) return;

      // Démarre la lecture de la chanson prévisualisée
      playSongInPlaylist(
        song: state.currentSong!,
        playlist: playlist,
        album: state.currentAlbum,
      );
      return;
    }

    // Cas 2 : Toggle normal
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void pause() => _player.pause();
  void resume() => _player.play();
  void next() => _player.seekToNext();
  void previous() => _player.seekToPrevious();

  void seek(Duration position) {
    if (state.playingSong == null) return;
    _player.seek(position);
  }

  // ═══════════════════════════════════════════════════════════
  // MODES DE LECTURE
  // ═══════════════════════════════════════════════════════════

  /// Cycle : off → all → one → off
  Future<void> cycleRepeatMode() async {
    final next = switch (state.repeatMode) {
      RepeatMode.off => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.off,
    };
    await setRepeatMode(next);
  }

  Future<void> setRepeatMode(RepeatMode mode) async {
    final loopMode = switch (mode) {
      RepeatMode.off => LoopMode.off,
      RepeatMode.one => LoopMode.one,
      RepeatMode.all => LoopMode.all,
    };
    await _player.setLoopMode(loopMode);
    state = state.copyWith(repeatMode: mode);
  }

  Future<void> toggleShuffle() async {
    final newValue = !state.shuffleEnabled;
    await _player.setShuffleModeEnabled(newValue);
    state = state.copyWith(shuffleEnabled: newValue);
  }
}

final playerProvider = NotifierProvider<PlayerNotifier, PlayerState>(
  () => PlayerNotifier(),
);