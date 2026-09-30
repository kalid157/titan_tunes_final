import 'package:titan_tunes/data/models/user_model.dart';
import 'package:titan_tunes/domaine/entities/user_entity.dart';


/// Usage :
///   final entity = userModel.toEntity();
///   final model  = userEntity.toModel();
extension UserModelMapper on UserModel {
  /// Convertit un UserModel (DATA) en UserEntity (DOMAIN)
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      username: username,
      avatarUrl: avatarUrl,
      token: token,
    );
  }
}

extension UserEntityMapper on UserEntity {
  /// Convertit un UserEntity (DOMAIN) en UserModel (DATA)
  UserModel toModel() {
    return UserModel(
      id: id,
      email: email,
      username: username,
      avatarUrl: avatarUrl,
      token: token,
    );
  }
}