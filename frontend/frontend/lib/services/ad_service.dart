import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class AdPortfolioItem {
  AdPortfolioItem({
    required this.id,
    required this.title,
    required this.mediaUrl,
    this.duration,
  });

  final String id;
  final String title;
  final String mediaUrl;
  final int? duration;

  factory AdPortfolioItem.fromJson(Map<String, dynamic> json) {
    return AdPortfolioItem(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      mediaUrl: json['mediaUrl'] ?? '',
      duration: json['duration'],
    );
  }
}

class AdService {
  AdService({required this.authService});

  final AuthService authService;

  Uri get _portfolioUrl =>
      Uri.parse('${authService.baseUrl}/api/ads/portfolio');

  /// Trae el portafolio público de videos publicitarios ya realizados
  /// (Ad con isActive: true y type: 'video').
  Future<List<AdPortfolioItem>> getPortfolio() async {
    try {
      final response = await http.get(_portfolioUrl);

      if (response.statusCode != 200) {
        return [];
      }

      final data = jsonDecode(response.body);
      final List<dynamic> items = data['data'] ?? [];

      return items
          .map((item) => AdPortfolioItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}