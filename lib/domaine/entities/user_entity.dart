/// Entité User (couche DOMAIN).
/// Représente l'utilisateur côté métier — ne dépend d'AUCUN package externe.
class UserEntity {
  final String id;
  final String email;
  final String? username;
  final String? avatarUrl;
  final String? token;

  const UserEntity({
    required this.id,
    required this.email,
    this.username,
    this.avatarUrl,
    this.token,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? username,
    String? avatarUrl,
    String? token,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      token: token ?? this.token,
    );
  }

  @override
  String toString() => 'UserEntity(id: $id, email: $email)';
}