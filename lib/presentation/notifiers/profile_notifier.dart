import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:titan_tunes/core/exceptions.dart/failures.dart';
import 'package:titan_tunes/domaine/entities/user_profile_entity.dart';
import 'package:titan_tunes/provider/auth_provider.dart';
import 'package:titan_tunes/provider/user_profile_providers.dart';

class ProfileState {
  final UserProfileEntity? user;
  final bool isLoading;
  final String? error;
  final bool usingFallback; //  indique si on utilise les données du login

  const ProfileState({
    this.user,
    this.isLoading = false,
    this.error,
    this.usingFallback = false,
  });

  ProfileState copyWith({
    UserProfileEntity? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? usingFallback,
  }) =>
      ProfileState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        usingFallback: usingFallback ?? this.usingFallback,
      );
}

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() => const ProfileState();

  Future<void> loadProfile(String clientId) async {
    if (clientId.isEmpty) {
      state = state.copyWith(error: 'Utilisateur non connecté');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user =
          await ref.read(userProfileRepositoryProvider).getProfile(clientId);

      //  Si l'API a répondu, on l'utilise
      if (user != null) {
        state = ProfileState(user: user, usingFallback: false);
        return;
      }

      //  Sinon (endpoint absent), on construit depuis auth
      _buildFromAuth(clientId);
    } on Failure catch (f) {
      //  Erreur réseau → fallback aussi (offline-first)
      _buildFromAuth(clientId, error: f.message);
    } catch (_) {
      _buildFromAuth(clientId, error: 'Erreur de chargement du profil');
    }
  }

  ///  Construit un UserProfileEntity depuis le user du authNotifier
  void _buildFromAuth(String clientId, {String? error}) {
    final authUser = ref.read(authNotifierProvider).user;

    if (authUser == null) {
      state = state.copyWith(
        isLoading: false,
        error: error ?? 'Aucune donnée utilisateur disponible',
      );
      return;
    }

    // Récupère le prénom/nom depuis username si dispo
    final username = authUser.username ?? authUser.email.split('@').first;
    final parts = username.split(' ');
    final firstName = parts.isNotEmpty ? parts.first : username;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final fallback = UserProfileEntity(
      trackingId: authUser.id,
      email: authUser.email,
      firstName: firstName,
      lastName: lastName,
      avatarUrl: authUser.avatarUrl,
      plan: SubscriptionPlan.free,
      monthlyPrice: 0.0,
    );

    state = ProfileState(
      user: fallback,
      usingFallback: true,
      error: error,
    );
  }

  void setPremium(SubscriptionPlan plan, {double price = 10.99}) {
    if (state.user == null) return;
    state = state.copyWith(
      user: state.user!.copyWith(plan: plan, monthlyPrice: price),
      usingFallback: false,
    );
  }

  void reset() => state = const ProfileState();
}

final profileNotifierProvider =
    NotifierProvider<ProfileNotifier, ProfileState>(() => ProfileNotifier());