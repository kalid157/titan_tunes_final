import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:titan_tunes/domaine/entities/song_entity.dart';

/// État du cache de durées
class DurationCacheState {
  final Map<String, Duration> durations;
  final bool isLoading;
  final int loaded;
  final int total;

  const DurationCacheState({
    this.durations = const {},
    this.isLoading = false,
    this.loaded = 0,
    this.total = 0,
  });

  /// Durée d'une chanson (null si pas encore chargée)
  Duration? getOf(String trackingId) => durations[trackingId];

  /// Somme des durées connues
  Duration totalOf(List<SongEntity> songs) {
    Duration total = Duration.zero;
    for (final s in songs) {
      final d = durations[s.trackingId];
      if (d != null) total += d;
    }
    return total;
  }

  /// Nombre de durées connues
  int knownCountOf(List<SongEntity> songs) {
    return songs.where((s) => durations.containsKey(s.trackingId)).length;
  }

  /// Progression 0.0 → 1.0
  double get progress => total == 0 ? 0 : loaded / total;

  DurationCacheState copyWith({
    Map<String, Duration>? durations,
    bool? isLoading,
    int? loaded,
    int? total,
  }) {
    return DurationCacheState(
      durations: durations ?? this.durations,
      isLoading: isLoading ?? this.isLoading,
      loaded: loaded ?? this.loaded,
      total: total ?? this.total,
    );
  }
}

///  Notifier qui précharge les durées de toutes les chansons
/// en utilisant un AudioPlayer secondaire (silencieux).
class DurationCacheNotifier extends Notifier<DurationCacheState> {
  AudioPlayer? _metaPlayer;
  bool _working = false;

  @override
  DurationCacheState build() {
    //  Player dédié aux métadonnées (pas pour jouer)
    _metaPlayer = AudioPlayer();

    ref.onDispose(() {
      _metaPlayer?.dispose();
      _metaPlayer = null;
    });

    return const DurationCacheState();
  }

  ///  Charge les durées manquantes pour une liste de chansons
  Future<void> loadAll(List<SongEntity> songs) async {
    if (_working) return;
    if (songs.isEmpty) return;

    _working = true;

    // Chansons dont la durée est inconnue
    final missing = songs
        .where((s) => !state.durations.containsKey(s.trackingId))
        .toList();

    // Toutes déjà en cache
    if (missing.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        loaded: state.durations.length,
        total: songs.length,
      );
      _working = false;
      return;
    }

    // Passer en mode chargement
    state = state.copyWith(
      isLoading: true,
      loaded: state.durations.length,
      total: songs.length,
    );

    final map = Map<String, Duration>.from(state.durations);

    //  Charge séquentiellement (le player ne peut charger qu'une URL à la fois)
    for (final song in missing) {
      try {
        // setUrl retourne la durée SANS jouer le son
        final duration = await _metaPlayer?.setUrl(song.audio);

        if (duration != null && duration > Duration.zero) {
          map[song.trackingId] = duration;

          // Mise à jour incrémentale (UI réactive)
          state = state.copyWith(
            durations: Map<String, Duration>.from(map),
            isLoading: true,
            loaded: map.length,
            total: songs.length,
          );
        }
      } catch (e) {
        debugPrint('⚠️ Durée introuvable pour "${song.titre}": $e');
      }
    }

    // Fin du chargement
    state = DurationCacheState(
      durations: map,
      isLoading: false,
      loaded: map.length,
      total: songs.length,
    );

    _working = false;
  }

  /// Vide le cache (utile pour debug)
  void clear() {
    state = const DurationCacheState();
  }
}

final durationCacheProvider =
    NotifierProvider<DurationCacheNotifier, DurationCacheState>(
  () => DurationCacheNotifier(),
);