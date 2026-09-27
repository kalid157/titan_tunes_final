import 'package:titan_tunes/data/models/register_model.dart';
import 'package:titan_tunes/domaine/entities/register_entity.dart';

/// Mapper RegisterEntity ↔ RegisterModel.
/// 
/// Usage :
///   final model  = registerEntity.toModel();
///   final entity = registerModel.toEntity();
extension RegisterEntityMapper on RegisterEntity {
  RegisterModel toModel() {
    return RegisterModel(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      phone: phone,
    );
  }
}

extension RegisterModelMapper on RegisterModel {
  RegisterEntity toEntity() {
    return RegisterEntity(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      phone: phone,
    );
  }
}