/// Modelo del usuario autenticado de SAN TV.
///
/// [avatarUrl] puede ser:
///  - null            -> sin foto (se muestra el ícono de persona)
///  - "avatar:3"      -> avatar prediseñado
///  - "https://..."   -> foto subida a Cloudinary
class AppUser {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final bool verified;
  final String role;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.verified = false,
    this.role = 'user',
  });

  bool get isAdmin => role == 'admin';

  factory AppUser.fromJson(Map<String, dynamic> json) {
    // El backend guarda el campo como "avatar"; se acepta también "avatarUrl".
    final rawAvatar = (json['avatar'] ?? json['avatarUrl'])?.toString();
    return AppUser(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      avatarUrl: (rawAvatar == null || rawAvatar.isEmpty) ? null : rawAvatar,
      verified: json['verified'] == true || json['isVerified'] == true,
      role: (json['role'] ?? 'user').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'verified': verified,
        'role': role,
      };
}