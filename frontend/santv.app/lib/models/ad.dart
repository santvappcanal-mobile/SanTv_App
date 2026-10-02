class AdItem {
  final String id;
  final String title;
  final String type; // video | banner | popup
  final String mediaUrl;
  final String? targetUrl;
  final int? duration;

  const AdItem({
    required this.id,
    required this.title,
    required this.type,
    required this.mediaUrl,
    this.targetUrl,
    this.duration,
  });

  factory AdItem.fromJson(Map<String, dynamic> json) {
    return AdItem(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString() ?? 'banner',
      mediaUrl: json['mediaUrl']?.toString() ?? '',
      targetUrl: json['targetUrl']?.toString(),
      duration: json['duration'] as int?,
    );
  }
}

/// Documento de publicidad (PDF), distinto de AdItem (video/banner/popup).
/// Se usa en la pestaña "Documentos" de PublicidadScreen.
class AdDocumentItem {
  final String id;
  final String title;
  final String mediaUrl;
  final String? publicId;

  const AdDocumentItem({
    required this.id,
    required this.title,
    required this.mediaUrl,
    this.publicId,
  });

  factory AdDocumentItem.fromJson(Map<String, dynamic> json) {
    return AdDocumentItem(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      mediaUrl: json['mediaUrl']?.toString() ?? '',
      publicId: json['publicId']?.toString(),
    );
  }
}
