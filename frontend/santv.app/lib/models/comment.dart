/// Un comentario de un video.
class CommentItem {
  final String id;
  final String text;
  final DateTime? createdAt;
  final String userId;
  final String userName;

  /// Puede ser null, "avatar:3" (prediseñado) o una URL de Cloudinary.
  final String? userAvatar;

  const CommentItem({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.userId,
    required this.userName,
    this.userAvatar,
  });

  factory CommentItem.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : <String, dynamic>{};

    final rawAvatar = user['avatar']?.toString();

    return CommentItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      userId: (user['_id'] ?? '').toString(),
      userName: (user['name'] ?? 'Usuario').toString(),
      userAvatar: (rawAvatar == null || rawAvatar.isEmpty) ? null : rawAvatar,
    );
  }
}