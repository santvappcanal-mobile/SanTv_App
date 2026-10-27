import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/report.dart';
import 'auth_service.dart';

class ReportException implements Exception {
  final String message;
  ReportException(this.message);

  @override
  String toString() => message;
}

class MyReportsResult {
  final List<Report> reports;
  final ReporterStats stats;
  const MyReportsResult(this.reports, this.stats);
}

class ReportService {
  ReportService(this.authService);

  final AuthService authService;

  static const _storage = FlutterSecureStorage();
  // Render (plan gratis) puede tardar en despertar: damos margen.
  static const _timeout = Duration(seconds: 60);

  String get _base => '${authService.baseUrl}/api/reports';

  Future<Map<String, String>> _headers({bool json = false}) async {
    final token = await _storage.read(key: 'auth_token');
    return {
      if (json) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decode(http.Response res) {
    Map<String, dynamic> body = {};
    if (res.body.isNotEmpty) {
      try {
        final parsed = jsonDecode(res.body);
        if (parsed is Map<String, dynamic>) body = parsed;
      } catch (_) {}
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ReportException(
        (body['message'] ?? 'Error del servidor (${res.statusCode})').toString(),
      );
    }
    return body;
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ReportException {
      rethrow;
    } on TimeoutException {
      throw ReportException('El servidor tardó demasiado en responder. Intenta de nuevo.');
    } on SocketException {
      throw ReportException('No se pudo conectar con el servidor. Revisa tu conexión.');
    } catch (e) {
      throw ReportException('Ocurrió un error inesperado: $e');
    }
  }

  List<Report> _parseList(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((e) => Report.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Enviar un reporte nuevo (multipart con la foto).
  Future<Report> createReport({
    required String title,
    required String description,
    required String category,
    required double latitude,
    required double longitude,
    required File image,
    String address = '',
  }) {
    return _guard(() async {
      final request = http.MultipartRequest('POST', Uri.parse(_base))
        ..headers.addAll(await _headers())
        ..fields['title'] = title
        ..fields['description'] = description
        ..fields['category'] = category
        ..fields['latitude'] = latitude.toString()
        ..fields['longitude'] = longitude.toString()
        ..fields['address'] = address
        ..files.add(await http.MultipartFile.fromPath('image', image.path));

      final streamed = await request.send().timeout(_timeout);
      final res = await http.Response.fromStream(streamed);
      final body = _decode(res);
      return Report.fromJson(Map<String, dynamic>.from(body['data'] as Map));
    });
  }

  /// Mis reportes + mis puntos e insignia.
  Future<MyReportsResult> getMine() {
    return _guard(() async {
      final res = await http
          .get(Uri.parse('$_base/mine'), headers: await _headers())
          .timeout(_timeout);
      final body = _decode(res);
      final stats = body['stats'] is Map
          ? ReporterStats.fromJson(Map<String, dynamic>.from(body['stats'] as Map))
          : const ReporterStats();
      return MyReportsResult(_parseList(body), stats);
    });
  }

  /// Reportes aprobados para el mapa.
  Future<List<Report>> getMap() {
    return _guard(() async {
      final res = await http
          .get(Uri.parse('$_base/map'), headers: await _headers())
          .timeout(_timeout);
      return _parseList(_decode(res));
    });
  }

  /// Cola de revisión (admin / editor).
  Future<List<Report>> getPending() {
    return _guard(() async {
      final res = await http
          .get(Uri.parse('$_base/pending'), headers: await _headers())
          .timeout(_timeout);
      return _parseList(_decode(res));
    });
  }

  Future<void> approve(String id, {String? title, String? description, String? category}) {
    return _guard(() async {
      final res = await http
          .put(
            Uri.parse('$_base/$id/approve'),
            headers: await _headers(json: true),
            body: jsonEncode({
              if (title != null) 'title': title,
              if (description != null) 'description': description,
              if (category != null) 'category': category,
            }),
          )
          .timeout(_timeout);
      _decode(res);
    });
  }

  Future<void> reject(String id, {String reason = ''}) {
    return _guard(() async {
      final res = await http
          .put(
            Uri.parse('$_base/$id/reject'),
            headers: await _headers(json: true),
            body: jsonEncode({'reason': reason}),
          )
          .timeout(_timeout);
      _decode(res);
    });
  }
}
