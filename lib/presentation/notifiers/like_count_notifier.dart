import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// État du compteur de likes
class LikeCountState {
  /// Compteur total par songTrackingId (base + likes locaux)
  final Map<String, int> counts;

  /// Base de départ (vient du backend quand il sera prêt)
  final Map<String, int> baseCounts;

  const LikeCountState({
    this.counts = const {},
    this.baseCounts = const {},
  });

  /// Compteur d'une chanson
  int countOf(String songTrackingId) {
    return counts[songTrackingId] ?? baseCounts[songTrackingId] ?? 0;
  }

  /// Version formatée : 1, 12, 1.2K, 3.4M
  String formattedCount(String songTrackingId) {
    return formatLikeCount(countOf(songTrackingId));
  }

  LikeCountState copyWith({
    Map<String, int>? counts,
    Map<String, int>? baseCounts,
  }) {
    return LikeCountState(
      counts: counts ?? this.counts,
      baseCounts: baseCounts ?? this.baseCounts,
    );
  }
}

///  Formate un nombre : 0, 1, 999, 1K, 1.2K, 15K, 1.5M
String formatLikeCount(int count) {
  if (count <= 0) return '0';
  if (count < 1000) return count.toString();
  if (count < 10000) {
    final k = count / 1000;
    return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}K';
  }
  if (count < 1000000) {
    return '${(count / 1000).truncate()}K';
  }
  if (count < 10000000) {
    final m = count / 1000000;
    return '${m.toStringAsFixed(m.truncateToDouble() == m ? 0 : 1)}M';
  }
  return '${(count / 1000000).truncate()}M';
}

class LikeCountNotifier extends Notifier<LikeCountState> {
  static const _keyCounts = 'like_counts';
  static const _keyBase = 'like_base_counts';

  @override
  LikeCountState build() {
    _loadLocal();
    return const LikeCountState();
  }

  Future<void> _loadLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final rawCounts = prefs.getString(_keyCounts);
      final rawBase = prefs.getString(_keyBase);

      final counts = rawCounts != null
          ? Map<String, int>.from(
              (jsonDecode(rawCounts) as Map).map(
                (k, v) => MapEntry(k.toString(), (v as num).toInt()),
              ),
            )
          : <String, int>{};

      final baseCounts = rawBase != null
          ? Map<String, int>.from(
              (jsonDecode(rawBase) as Map).map(
                (k, v) => MapEntry(k.toString(), (v as num).toInt()),
              ),
            )
          : <String, int>{};

      state = LikeCountState(counts: counts, baseCounts: baseCounts);
    } catch (e) {
      debugPrint('⚠️ Erreur chargement likes: $e');
    }
  }

  Future<void> _saveLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCounts, jsonEncode(state.counts));
      await prefs.setString(_keyBase, jsonEncode(state.baseCounts));
    } catch (e) {
      debugPrint(' Erreur sauvegarde likes: $e');
    }
  }

  /// Incrémente le compteur d'une chanson
  void increment(String songTrackingId) {
    final newCounts = Map<String, int>.from(state.counts);
    newCounts[songTrackingId] = (newCounts[songTrackingId] ?? 0) + 1;
    state = state.copyWith(counts: newCounts);
    _saveLocal();
  }

  ///  Décrémente le compteur (minimum 0)
  void decrement(String songTrackingId) {
    final newCounts = Map<String, int>.from(state.counts);
    final current = newCounts[songTrackingId] ?? 0;
    if (current > 0) {
      newCounts[songTrackingId] = current - 1;
      state = state.copyWith(counts: newCounts);
      _saveLocal();
    }
  }

  ///  Enregistre la base depuis le backend (total de tous les utilisateurs)
  void setBaseCounts(Map<String, int> bases) {
    state = state.copyWith(baseCounts: bases);
    _saveLocal();
  }

  ///  Enregistre la base pour une seule chanson
  void setBaseCount(String songTrackingId, int count) {
    final newBase = Map<String, int>.from(state.baseCounts);
    newBase[songTrackingId] = count;
    state = state.copyWith(baseCounts: newBase);
    _saveLocal();
  }

  /// Vide le cache (au logout)
  Future<void> clear() async {
    state = const LikeCountState();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyCounts);
      await prefs.remove(_keyBase);
    } catch (_) {}
  }
}

final likeCountProvider =
    NotifierProvider<LikeCountNotifier, LikeCountState>(
  () => LikeCountNotifier(),
);