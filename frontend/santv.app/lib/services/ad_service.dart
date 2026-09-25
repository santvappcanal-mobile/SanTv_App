import 'dart:convert';
import 'dart:io';
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

class AdDocumentItem {
  AdDocumentItem({
    required this.id,
    required this.title,
    required this.mediaUrl,
  });

  final String id;
  final String title;
  final String mediaUrl;

  factory AdDocumentItem.fromJson(Map<String, dynamic> json) {
    return AdDocumentItem(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      mediaUrl: json['mediaUrl'] ?? '',
    );
  }
}

class AdService {
  AdService({required this.authService});

  final AuthService authService;

  Uri get _portfolioUrl =>
      Uri.parse('${authService.baseUrl}/api/ads/portfolio');

  Uri get _documentsUrl =>
      Uri.parse('${authService.baseUrl}/api/ads/documents');

  Uri get _uploadDocumentUrl =>
      Uri.parse('${authService.baseUrl}/api/ads/document');

  Uri _deleteUrl(String id) =>
      Uri.parse('${authService.baseUrl}/api/ads/$id');

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

  /// Trae los documentos/reseñas en PDF (público)
  /// (Ad con isActive: true y type: 'document').
  Future<List<AdDocumentItem>> getDocuments() async {
    try {
      final response = await http.get(_documentsUrl);

      if (response.statusCode != 200) {
        return [];
      }

      final data = jsonDecode(response.body);
      final List<dynamic> items = data['data'] ?? [];

      return items
          .map((item) => AdDocumentItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Sube un PDF nuevo como documento/reseña. Solo admin.
  Future<bool> uploadDocument(File pdf, String title) async {
    try {
      final token = await authService.getToken();
      final request = http.MultipartRequest('POST', _uploadDocumentUrl)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['title'] = title
        ..files.add(await http.MultipartFile.fromPath('archivo', pdf.path));

      final streamedResponse = await request.send();
      return streamedResponse.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  /// Elimina un documento por su _id. Solo admin.
  Future<bool> deleteDocument(String id) async {
    try {
      final token = await authService.getToken();
      final response = await http.delete(
        _deleteUrl(id),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}