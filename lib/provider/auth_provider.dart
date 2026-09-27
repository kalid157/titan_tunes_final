import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:titan_tunes/config/service/app_endpoint.dart';
import 'package:titan_tunes/config/service/connectivity_service.dart';
import 'package:titan_tunes/data/datasources/auth_remote_datasource.dart';
import 'package:titan_tunes/data/repositories/auth_repository_impl.dart';
import 'package:titan_tunes/domaine/entities/user_entity.dart';
import 'package:titan_tunes/domaine/repositories/auth_repository.dart';
import 'package:titan_tunes/domaine/usecases/login_usecase.dart';
import 'package:titan_tunes/presentation/notifiers/auth_notifier.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppEndpoint.baseUrl,
    connectTimeout: AppEndpoint.connectTimeout,
    receiveTimeout: AppEndpoint.receiveTimeout,
    headers: {'Content-Type': 'application/json'},
  ));

  // ⭐ Log complet en mode debug
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => debugPrint('🌐 $obj'),
    ));
  }

  return dio;
});

class AuthStateNotifier extends StateNotifier<UserEntity?> {
  AuthStateNotifier(authUseCases) : super(null);

  get authUseCases => null;

 // final AuthUseCases authUseCases;

  //AuthStateNotifier(this.authUseCases) : super(null);

  void setUser(UserEntity user) {
    state = user;
  }

  Future<void> register(
      BuildContext context, 
      String firstname,
      String lastname,
      String email,
      String password,
      String phone) async {
    final result =
        await authUseCases.register(firstname, lastname, email, password, phone);
    result.fold(
      (errorMessage) {
        if (kDebugMode) {
          print("Erreur de connexion: $errorMessage");
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('erreur de création du compte')),
        );
      },
      (user) => state = user,
    );
  }

  Future<void> login(
      BuildContext context, String email, String password) async {
    try {
      final response = await authUseCases.login(email, password);
      if (kDebugMode) {
        print('LOGIN response => $response');
      }
      response.fold(
        (errorMessage) {
          if (kDebugMode) {
            print("Erreur de connexion: $errorMessage");
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur de connexion')),
          );
        },
        (user) {
          state = user;
          if (kDebugMode) {
            print("Utilisateur connecté : $user");
          }
          GoRouter.of(context).go('/home');
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print("Erreur inattendue lors de la connexion: $e");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur inattendue lors de la connexion.')),
      );
    }
  }

  Future<void> loginWithGoogle(BuildContext context) async {
    final result = await authUseCases.googleLogin();
    result.fold(
      (errorMessage) {
        if (kDebugMode) {
          print('Erreur de connexion Google: $errorMessage');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur de connexion avec Google')),
        );
      },
      (user) {
        state = user;
        GoRouter.of(context).go('/home');
      },
    );
  }

  Future<void> logout() async {
    await authUseCases.logout();
    state = null;
  }
}


final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, UserEntity?>((ref) {
  final authUseCases = ref.watch(authUseCasesProvider);
  return AuthStateNotifier(authUseCases);
});

final authUseCasesProvider = Provider<dynamic>((ref) => null);

// ─── Infra ─────────────────────────────────────────────



final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

// ─── Data ──────────────────────────────────────────────
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    dio: ref.watch(dioProvider),
    connectivity: ref.watch(connectivityServiceProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
});

// ─── Domain ────────────────────────────────────────────
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

// ─── Presentation ──────────────────────────────────────
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});