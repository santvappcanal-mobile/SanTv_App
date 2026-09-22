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
  });

  bool get isYoutube =>
      videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be');

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
    );
  }
}
