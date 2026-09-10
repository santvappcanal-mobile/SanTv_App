class ContentByType {
  final int movie;
  final int series;
  final int documentary;

  const ContentByType({this.movie = 0, this.series = 0, this.documentary = 0});

  factory ContentByType.fromJson(Map<String, dynamic> json) {
    return ContentByType(
      movie: (json['movie'] ?? 0) as int,
      series: (json['series'] ?? 0) as int,
      documentary: (json['documentary'] ?? 0) as int,
    );
  }
}

class TopContentItem {
  final String id;
  final String title;
  final int views;
  final String type;
  final String thumbnailUrl;

  const TopContentItem({
    required this.id,
    required this.title,
    required this.views,
    required this.type,
    required this.thumbnailUrl,
  });

  factory TopContentItem.fromJson(Map<String, dynamic> json) {
    return TopContentItem(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      views: (json['views'] ?? 0) as int,
      type: json['type']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
    );
  }
}

class AdminStats {
  final int totalUsers;
  final int activeUsers;
  final Map<String, int> usersByRole;

  final int totalContent;
  final int activeContent;
  final int inactiveContent;
  final int totalViews;
  final ContentByType contentByType;
  final List<TopContentItem> topContent;

  final int totalAds;
  final int activeAds;

  final int totalLiveEvents;
  final int liveNow;

  const AdminStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.usersByRole,
    required this.totalContent,
    required this.activeContent,
    required this.inactiveContent,
    required this.totalViews,
    required this.contentByType,
    required this.topContent,
    required this.totalAds,
    required this.activeAds,
    required this.totalLiveEvents,
    required this.liveNow,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    final users = json['users'] as Map<String, dynamic>? ?? {};
    final content = json['content'] as Map<String, dynamic>? ?? {};
    final ads = json['ads'] as Map<String, dynamic>? ?? {};
    final liveEvents = json['liveEvents'] as Map<String, dynamic>? ?? {};

    final byRole = <String, int>{};
    (users['byRole'] as Map<String, dynamic>? ?? {}).forEach((key, value) {
      byRole[key] = (value ?? 0) as int;
    });

    final topContentJson = content['topContent'] as List<dynamic>? ?? [];

    return AdminStats(
      totalUsers: (users['total'] ?? 0) as int,
      activeUsers: (users['active'] ?? 0) as int,
      usersByRole: byRole,
      totalContent: (content['total'] ?? 0) as int,
      activeContent: (content['active'] ?? 0) as int,
      inactiveContent: (content['inactive'] ?? 0) as int,
      totalViews: (content['totalViews'] ?? 0) as int,
      contentByType: ContentByType.fromJson(
        content['byType'] as Map<String, dynamic>? ?? {},
      ),
      topContent: topContentJson
          .map((e) => TopContentItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAds: (ads['total'] ?? 0) as int,
      activeAds: (ads['active'] ?? 0) as int,
      totalLiveEvents: (liveEvents['total'] ?? 0) as int,
      liveNow: (liveEvents['live'] ?? 0) as int,
    );
  }
}
