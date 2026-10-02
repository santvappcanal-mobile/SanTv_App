class AdDocumentItem {
  final String id;
  final String title;
  final String mediaUrl;

  AdDocumentItem({
    required this.id,
    required this.title,
    required this.mediaUrl,
  });

  factory AdDocumentItem.fromJson(Map<String, dynamic> json) {
    return AdDocumentItem(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      mediaUrl: json['mediaUrl'] ?? json['url'] ?? '',
    );
  }
}
