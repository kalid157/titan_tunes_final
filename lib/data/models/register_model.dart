/// Modèle JSON de la requête POST /user/registerClient (couche DATA).
class RegisterModel {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phone;

  const RegisterModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
  });

  /// Convertit le modèle en JSON pour Dio
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'phone': phone,
    };
  }

  /// Optionnel : depuis JSON (utile si le backend renvoie le même format)
  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }
}