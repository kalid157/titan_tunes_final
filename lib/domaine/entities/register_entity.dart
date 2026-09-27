/// Entité métier pour l'inscription (couche DOMAIN).
class RegisterEntity {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phone;

  const RegisterEntity({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
  });

  @override
  String toString() =>
      'RegisterEntity(firstName: $firstName, email: $email)';
}