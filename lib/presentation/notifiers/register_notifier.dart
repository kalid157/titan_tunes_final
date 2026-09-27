import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:titan_tunes/core/exceptions.dart/failures.dart';
import 'package:titan_tunes/provider/register_providers.dart';

/// État exposé par le RegisterNotifier
class RegisterState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const RegisterState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  RegisterState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class RegisterNotifier extends Notifier<RegisterState> {
  @override
  RegisterState build() => const RegisterState();

  /// Inscription : retourne `true` si succès, `false` sinon
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
  }) async {
    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      clearError: true,
    );

    try {
      await ref.read(registerUseCaseProvider)(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
      );

      state = const RegisterState(isLoading: false, isSuccess: true);
      return true;
    } on Failure catch (f) {
      state = state.copyWith(isLoading: false, errorMessage: f.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Une erreur inattendue est survenue',
      );
      return false;
    }
  }

  /// Réinitialise l'état (après affichage du SnackBar par exemple)
  void reset() {
    state = const RegisterState();
  }
}