v/// Modelo del usuario autenticado de SAN TV.
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
    return AppUser(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      verified: json['verified'] == true,
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