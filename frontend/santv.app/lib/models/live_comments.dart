/// Comentario del chat en vivo del canal.
class LiveComment {
  const LiveComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.avatarUrl,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String userName;
  final String avatarUrl;
  final String text;
  final DateTime createdAt;

  factory LiveComment.fromJson(Map<String, dynamic> json) {
    return LiveComment(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      userName: (json['userName'] ?? 'Usuario').toString(),
      avatarUrl: (json['avatarUrl'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString())?.toLocal() ??
              DateTime.now(),
    );
  }
}
