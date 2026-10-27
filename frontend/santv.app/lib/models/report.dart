class ReportAnalysis {
  final bool analyzed;
  final String suggestedTitle;
  final String summary;
  final String suggestedCategory;
  final int suspicionScore;
  final String suspicionReason;

  const ReportAnalysis({
    this.analyzed = false,
    this.suggestedTitle = '',
    this.summary = '',
    this.suggestedCategory = '',
    this.suspicionScore = 0,
    this.suspicionReason = '',
  });

  factory ReportAnalysis.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ReportAnalysis();
    return ReportAnalysis(
      analyzed: json['analyzed'] == true,
      suggestedTitle: (json['suggestedTitle'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      suggestedCategory: (json['suggestedCategory'] ?? '').toString(),
      suspicionScore: int.tryParse('${json['suspicionScore'] ?? 0}') ?? 0,
      suspicionReason: (json['suspicionReason'] ?? '').toString(),
    );
  }
}

class Report {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String address;
  final String status; // pending | approved | rejected
  final String rejectionReason;
  final DateTime? createdAt;
  final String authorName;
  final String authorBadge;
  final int authorPoints;
  final int authorApproved;
  final int nearbyReports;
  final ReportAnalysis ai;

  const Report({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    this.address = '',
    this.status = 'pending',
    this.rejectionReason = '',
    this.createdAt,
    this.authorName = '',
    this.authorBadge = '',
    this.authorPoints = 0,
    this.authorApproved = 0,
    this.nearbyReports = 0,
    this.ai = const ReportAnalysis(),
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  factory Report.fromJson(Map<String, dynamic> json) {
    // "author" puede venir como id (String) o como objeto poblado (Map)
    String authorName = '';
    String authorBadge = '';
    int authorPoints = 0;
    int authorApproved = 0;
    final author = json['author'];
    if (author is Map) {
      authorName = (author['name'] ?? '').toString();
      authorBadge = (author['reporterBadge'] ?? '').toString();
      authorPoints = int.tryParse('${author['reporterPoints'] ?? 0}') ?? 0;
      authorApproved = int.tryParse('${author['approvedReports'] ?? 0}') ?? 0;
    }

    return Report(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? 'Noticias').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      latitude: double.tryParse('${json['latitude'] ?? 0}') ?? 0,
      longitude: double.tryParse('${json['longitude'] ?? 0}') ?? 0,
      address: (json['address'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      rejectionReason: (json['rejectionReason'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString())?.toLocal(),
      authorName: authorName,
      authorBadge: authorBadge,
      authorPoints: authorPoints,
      authorApproved: authorApproved,
      nearbyReports: int.tryParse('${json['nearbyReports'] ?? 0}') ?? 0,
      ai: ReportAnalysis.fromJson(
        json['ai'] is Map ? Map<String, dynamic>.from(json['ai'] as Map) : null,
      ),
    );
  }
}

class ReporterStats {
  final int points;
  final int approved;
  final String badge;

  const ReporterStats({this.points = 0, this.approved = 0, this.badge = ''});

  factory ReporterStats.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ReporterStats();
    return ReporterStats(
      points: int.tryParse('${json['points'] ?? 0}') ?? 0,
      approved: int.tryParse('${json['approved'] ?? 0}') ?? 0,
      badge: (json['badge'] ?? '').toString(),
    );
  }
}
