import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:titan_tunes/config/service/app_endpoint.dart';
import 'package:titan_tunes/domaine/entities/song_entity.dart';
import 'package:titan_tunes/provider/auth_provider.dart' show dioProvider;
//import 'package:titan_tunes/presentation/provider/auth_providers.dart'
    ///show dioProvider;

class NewSongsState {
  final List<SongEntity> newSongs;
  final Set<String> knownIds;
  final int unreadCount;
  final bool endpointAvailable; //  indique si l'API répond

  const NewSongsState({
    this.newSongs = const [],
    this.knownIds = const {},
    this.unreadCount = 0,
    this.endpointAvailable = true,
  });

  NewSongsState copyWith({
    List<SongEntity>? newSongs,
    Set<String>? knownIds,
    int? unreadCount,
    bool? endpointAvailable,
  }) =>
      NewSongsState(
        newSongs: newSongs ?? this.newSongs,
        knownIds: knownIds ?? this.knownIds,
        unreadCount: unreadCount ?? this.unreadCount,
        endpointAvailable: endpointAvailable ?? this.endpointAvailable,
      );
}

class WhatsNewNotifier extends Notifier<NewSongsState> {
  Timer? _timer;
  int _consecutiveErrors = 0;

  @override
  NewSongsState build() {
    ref.onDispose(() => _timer?.cancel());
    return const NewSongsState();
  }

  void start() {
    _timer?.cancel();
    _fetch();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _fetch());
  }

  void stop() => _timer?.cancel();
  /// Rafraîchit immédiatement sans redémarrer le timer
Future<void> refreshNow() => _fetch();

  Future<void> _fetch() async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get(AppEndpoint.newSongs);
      final data = res.data;

      final List<dynamic> list = data is List
          ? data
          : (data is Map && data['data'] is List)
              ? data['data']
              : [];

      final songs = list
          .whereType<Map<String, dynamic>>()
          .map((json) => SongEntity(
                trackingId: json['trackingId'] as String? ?? '',
                titre: json['titre'] as String? ?? '',
                audio: json['audio'] as String? ?? '',
                artiste: json['artiste'] as String? ?? '',
              ))
          .toList();

      final newIds = songs.map((s) => s.trackingId).toSet();
      final knownIds = state.knownIds;

      int unread = state.unreadCount;
      if (knownIds.isNotEmpty) {
        unread += newIds.difference(knownIds).length;
      }

      _consecutiveErrors = 0; // Reset en cas de succès
      state = state.copyWith(
        newSongs: songs,
        knownIds: newIds,
        unreadCount: unread,
        endpointAvailable: true,
      );
    } on DioException catch (e) {
      _consecutiveErrors++;

      //  Endpoint pas encore disponible → on arrête le polling
      if (e.response?.statusCode == 404 ||
          e.response?.statusCode == 500 ||
          e.response?.statusCode == 501) {
        debugPrint('📵 /song/new indisponible — arrêt du polling');
        stop();
        state = state.copyWith(endpointAvailable: false);
        return;
      }

      // Après 3 erreurs consécutives → arrêt
      if (_consecutiveErrors >= 3) {
        debugPrint('📵 3 erreurs consécutives — arrêt du polling');
        stop();
      }
    } catch (_) {
      // silencieux
    }
  }

  void markAllRead() {
    state = state.copyWith(unreadCount: 0);
  }
}

final whatsNewProvider =
    NotifierProvider<WhatsNewNotifier, NewSongsState>(() => WhatsNewNotifier());