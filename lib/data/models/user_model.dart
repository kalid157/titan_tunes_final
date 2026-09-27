/// Modèle User (couche DATA) — reflète la réponse JSON de l'API Swagger.
/// C'est ici qu'on définit fromJson / toJson, jamais dans l'Entity.
class UserModel {
  final String id;
  final String email;
  final String? username;
  final String? avatarUrl;
  final String? token;

  const UserModel({
    required this.id,
    required this.email,
    this.username,
    this.avatarUrl,
    this.token,
  });

  /// Construit un UserModel depuis la réponse JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
  return UserModel(
    // ⭐ Lit 'trackingId' en priorité (c'est ce que ton backend renvoie)
    id: (json['trackingId'] ?? json['id'] ?? json['_id'] ?? '').toString(),
    email: json['email'] as String? ?? '',
    username: json['firstName'] != null
        ? '${json['firstName']} ${json['lastName'] ?? ''}'.trim()
        : json['username'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
    token: json['token'] as String?,
  );
}
  /// Convertit le UserModel en JSON (utile pour la couche cache)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (username != null) 'username': username,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (token != null) 'token': token,
    };
  }
}