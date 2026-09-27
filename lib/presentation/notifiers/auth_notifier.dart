import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:titan_tunes/core/exceptions.dart/failures.dart';
import 'package:titan_tunes/domaine/entities/user_entity.dart';
import 'package:titan_tunes/provider/auth_provider.dart';

/// État exposé par le AuthNotifier
class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Notifier qui pilote les actions d'authentification
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  /// Login : retourne `true` si succès, `false` sinon
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Appel du UseCase
      final user = await ref.read(loginUseCaseProvider)(
        email: email,
        password: password,
      );

      state = AuthState(user: user, isLoading: false);
      return true;
    } on Failure catch (f) {
      // Failure métier → message propre pour l'UI
      state = state.copyWith(isLoading: false, errorMessage: f.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Une erreur inattendue est survenue',
      );
      return false;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthState();
  }
}