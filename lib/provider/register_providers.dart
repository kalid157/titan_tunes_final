import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:titan_tunes/data/datasources/register_datasource.dart';
import 'package:titan_tunes/data/repositories/register_repository_impl.dart';
import 'package:titan_tunes/domaine/repositories/register_repository.dart';
import 'package:titan_tunes/domaine/usecases/register_usecase.dart';
import 'package:titan_tunes/presentation/notifiers/register_notifier.dart';
import 'package:titan_tunes/provider/auth_provider.dart';  // pour dioProvider, connectivityServiceProvider

// --- Data ---
final registerRemoteDataSourceProvider =
    Provider<RegisterRemoteDataSource>((ref) {
  return RegisterRemoteDataSourceImpl(
    dio: ref.watch(dioProvider),
    connectivity: ref.watch(connectivityServiceProvider),
  );
});

final registerRepositoryProvider = Provider<RegisterRepository>((ref) {
  return RegisterRepositoryImpl(
    remoteDataSource: ref.watch(registerRemoteDataSourceProvider),
  );
});

// --- Domain ---
final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(registerRepositoryProvider));
});

// --- Presentation ---
final registerNotifierProvider =
    NotifierProvider<RegisterNotifier, RegisterState>(() {
  return RegisterNotifier();
});