import 'package:titan_tunes/core/exceptions.dart/exceptions.dart';
import 'package:titan_tunes/core/exceptions.dart/failures.dart';
import 'package:titan_tunes/data/datasources/register_datasource.dart';
import 'package:titan_tunes/data/mappers/register_mapper.dart';
import 'package:titan_tunes/data/mappers/user_mapper.dart';
import 'package:titan_tunes/domaine/entities/register_entity.dart';
import 'package:titan_tunes/domaine/entities/user_entity.dart';
import 'package:titan_tunes/domaine/repositories/register_repository.dart';

class RegisterRepositoryImpl implements RegisterRepository {
  final RegisterRemoteDataSource _remoteDataSource;

  RegisterRepositoryImpl({required RegisterRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<UserEntity> register(RegisterEntity entity) async {
    try {
      // 1. Entity → Model (mapper)
      final model = entity.toModel();

      // 2. Appel DataSource
      final userModel = await _remoteDataSource.register(model);

      // 3. Model → Entity (mapper user)
      return userModel.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on UnauthorizedException catch (e) {
      throw AuthFailure(e.message);
    } on ParsingException catch (e) {
      throw ServerFailure(e.message);
    } catch (_) {
      throw const UnexpectedFailure();
    }
  }
}