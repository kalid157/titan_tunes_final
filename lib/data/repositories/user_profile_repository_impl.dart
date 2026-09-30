import 'package:titan_tunes/core/exceptions.dart/exceptions.dart';
import 'package:titan_tunes/core/exceptions.dart/failures.dart';
import 'package:titan_tunes/data/datasources/user_profile_datasource.dart';
import 'package:titan_tunes/data/mappers/user_profile_mapper.dart';
import 'package:titan_tunes/domaine/entities/user_profile_entity.dart';
import 'package:titan_tunes/domaine/repositories/user_profile_repository.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource _remote;
  UserProfileRepositoryImpl({required UserProfileRemoteDataSource remote})
      : _remote = remote;

  @override
  Future<UserProfileEntity?> getProfile(String clientId) async {
    try {
      final model = await _remote.getProfile(clientId);
      //  Si null (endpoint absent), on remonte null
      return model?.toEntity();
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on UnauthorizedException catch (e) {
      throw AuthFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> updatePlan(String clientId, SubscriptionPlan plan) async {
    // TODO: appel API
  }
}