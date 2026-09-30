import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan_tunes/domaine/entities/song_entity.dart';

// ═══════════════════════════════════════════════════════════════
// ENTITÉ

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
        listenedAt: DateTime.tryParse(json['listenedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}


// ÉTAT

class ListeningHistoryState {
  final List<ListeningHistoryEntity> items;
  final bool isLoading;

  const ListeningHistoryState({
    this.items = const [],
    this.isLoading = false,
  });
}


// NOTIFIER

class ListeningHistoryNotifier extends Notifier<ListeningHistoryState> {
  static const _key = 'listening_history';
  static const _maxItems = 100;

  @override
  ListeningHistoryState build() {
    _load();
    return const ListeningHistoryState();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;

      final List<dynamic> list = jsonDecode(raw);
      state = ListeningHistoryState(
        items: list
            .whereType<Map<String, dynamic>>()
            .map(ListeningHistoryEntity.fromJson)
            .toList(),
      );
    } catch (_) {
      // silencieux
    }
  }

  ///  Appelé à chaque playSong
  Future<void> record(SongEntity song, {String? albumImageUrl}) async {
    // Évite les doublons consécutifs
    if (state.items.isNotEmpty &&
        state.items.first.songId == song.trackingId) {
      return;
    }

    final entry = ListeningHistoryEntity(
      songId: song.trackingId,
      songTitle: song.titre,
      artist: song.artiste,
      albumImageUrl: albumImageUrl,
      listenedAt: DateTime.now(),
    );

    final updated = [entry, ...state.items].take(_maxItems).toList();
    state = ListeningHistoryState(items: updated);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(updated.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }

  Future<void> clear() async {
    state = const ListeningHistoryState();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }
}


// PROVIDER   C'est CE nom qui doit exister

final listeningHistoryProvider =
    NotifierProvider<ListeningHistoryNotifier, ListeningHistoryState>(
  () => ListeningHistoryNotifier(),
);