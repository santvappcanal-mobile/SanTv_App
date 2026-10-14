/// Video de la pestaña "Referencias" de Publicidad.
class ReferenceVideoItem {
  const ReferenceVideoItem({
    required this.id,
    required this.title,
    required this.mediaUrl,
    this.createdAt,
  });

  final String id;
  final String title;
  final String mediaUrl;
  final DateTime? createdAt;

  factory ReferenceVideoItem.fromJson(Map<String, dynamic> json) {
    return ReferenceVideoItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      mediaUrl: (json['mediaUrl'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }

  /// Miniatura automática de Cloudinary: la misma URL del video pero con
  /// extensión .jpg devuelve un fotograma del video.
  String get thumbnailUrl {
    final dot = mediaUrl.lastIndexOf('.');
    if (dot == -1 || dot < mediaUrl.lastIndexOf('/')) return mediaUrl;
    return '${mediaUrl.substring(0, dot)}.jpg';
  }
}