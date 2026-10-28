import 'report.dart';

class ContentItem {
  final String id;
  final String title;
  final String description;
  final String type;
  final List<String> genres;
  final String videoUrl;
  final String thumbnailUrl;
  final int duration;
  final int? releaseYear;
  final bool isPremium;
  final int views;

  /// Solo se llena cuando la noticia nació de un reporte ciudadano aprobado.
  final String reportId;
  final DateTime? createdAt;

  const ContentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.genres,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.duration,
    this.releaseYear,
    required this.isPremium,
    required this.views,
    this.reportId = '',
    this.createdAt,
  });

  bool get isYoutube =>
      videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be');

  /// true si es una noticia del Reportero Ciudadano (solo foto, sin video).
  /// El respaldo por texto cubre listas del backend que no devuelvan reportId.
  bool get isCitizenReport =>
      reportId.isNotEmpty ||
      (videoUrl.isEmpty && description.contains('Reportado por '));

  static final RegExp _authorLine = RegExp(r'\s*Reportado por ([^\n]+)\s*$');

  /// Convierte la noticia en un [Report] para mostrarla en la pantalla de detalle.
  /// El nombre del autor viaja en la última línea de la descripción
  /// ("Reportado por X"); aquí se separa para mostrarlo aparte.
  Report toReport() {
    final match = _authorLine.firstMatch(description);
    final cleanDescription =
        match == null ? description : description.substring(0, match.start).trim();
    final category = genres.isNotEmpty && genres.first.isNotEmpty
        ? '${genres.first[0].toUpperCase()}${genres.first.substring(1)}'
        : 'Noticias';

    return Report(
      id: reportId.isNotEmpty ? reportId : id,
      title: title,
      description: cleanDescription,
      category: category,
      imageUrl: thumbnailUrl,
      latitude: 0,
      longitude: 0,
      status: 'approved',
      createdAt: createdAt,
      authorName: match?.group(1)?.trim() ?? '',
    );
  }

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      genres: (json['genres'] as List<dynamic>? ?? [])
          .map((g) => g.toString())
          .toList(),
      videoUrl: json['videoUrl']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      duration: (json['duration'] ?? 0) as int,
      releaseYear: json['releaseYear'] as int?,
      isPremium: json['isPremium'] as bool? ?? false,
      views: (json['views'] ?? 0) as int,
      reportId: json['reportId']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toLocal(),
    );
  }
}