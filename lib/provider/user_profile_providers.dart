import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:titan_tunes/data/datasources/user_profile_datasource.dart';
import 'package:titan_tunes/data/repositories/user_profile_repository_impl.dart';
import 'package:titan_tunes/domaine/repositories/user_profile_repository.dart';
import 'package:titan_tunes/provider/auth_provider.dart' show dioProvider, connectivityServiceProvider;
//import 'package:titan_tunes/presentation/provider/auth_providers.dart' show dioProvider, connectivityServiceProvider;

// ─── Data ─────────────────────────────────────────────────
final userProfileRemoteDataSourceProvider =
    Provider<UserProfileRemoteDataSource>((ref) {
  return UserProfileRemoteDataSourceImpl(
    dio: ref.watch(dioProvider),
    connectivity: ref.watch(connectivityServiceProvider),
  );
});

// ─── Repository ────────────────────────────────────────────
final userProfileRepositoryProvider =
    Provider<UserProfileRepository>((ref) {
  return UserProfileRepositoryImpl(
    remote: ref.watch(userProfileRemoteDataSourceProvider),
  );
});