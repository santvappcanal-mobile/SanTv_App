/// Imagen de la galería del Portafolio (Ad con type: 'gallery').
class GalleryItem {
  final String id;
  final String title;
  final String mediaUrl;

  /// Descripción opcional que el admin escribe al subir la imagen.
  final String description;

  const GalleryItem({
    required this.id,
    required this.title,
    required this.mediaUrl,
    this.description = '',
  });

  factory GalleryItem.fromJson(Map<String, dynamic> json) {
    return GalleryItem(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      mediaUrl: json['mediaUrl']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}