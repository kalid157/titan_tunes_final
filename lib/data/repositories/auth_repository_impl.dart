import 'package:titan_tunes/core/exceptions.dart/exceptions.dart';
import 'package:titan_tunes/core/exceptions.dart/failures.dart';
import 'package:titan_tunes/data/datasources/auth_remote_datasource.dart';
import 'package:titan_tunes/data/mappers/user_mapper.dart'; 
import 'package:titan_tunes/domaine/entities/user_entity.dart';
import 'package:titan_tunes/domaine/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Appel au DataSource → UserModel
      final userModel = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      // 2. Utilisation du MAPPER : UserModel → UserEntity
      return userModel.toEntity();
    } on UnauthorizedException catch (e) {
      throw AuthFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on ParsingException catch (e) {
      throw ServerFailure(e.message);
    } catch (_) {
      throw const UnexpectedFailure();
    }
  }

  @override
  Future<void> logout() async {
    // TODO: Appeler l'endpoint logout et supprimer le token
  }
}