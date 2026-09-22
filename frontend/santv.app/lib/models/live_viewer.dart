/// Modelo que representa a un espectador conectado a una
/// transmisión EN VIVO en tiempo real.
class LiveViewer {
  final String id;
  final String name;
  final String? avatarUrl;
  final DateTime joinedAt;

  const LiveViewer({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.joinedAt,
  });

  factory LiveViewer.fromJson(Map<String, dynamic> json) {
    return LiveViewer(
      id: (json['id'] ?? json['userId'] ?? '').toString(),
      name: (json['name'] ?? 'Espectador').toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      joinedAt: DateTime.tryParse(json['joinedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'joinedAt': joinedAt.toIso8601String(),
      };

  @override
  bool operator ==(Object other) => other is LiveViewer && other.id == id;

  @override
  int get hashCode => id.hashCode;
}