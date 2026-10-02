class AdminUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final bool isVerified;

  /// true si el usuario está dentro de la app ahora mismo
  /// (calculado por el backend con ping / lastSeen).
  final bool isOnline;
  final DateTime? createdAt;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.isVerified,
    this.isOnline = false,
    this.createdAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      isActive: json['isActive'] as bool? ?? true,
      isVerified: json['isVerified'] as bool? ?? false,
      isOnline: json['online'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}