import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/content.dart';
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

  /// Detecta el tipo real de la imagen leyendo sus primeros bytes.
  /// Las fotos que entrega el selector a veces llegan sin extensión y el
  /// servidor las rechazaba por no saber que eran imágenes.
  Future<(MediaType, String)> _imageType(File file) async {
    final raf = await file.open();
    try {
      final b = await raf.read(12);
      if (b.length >= 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) {
        return (MediaType('image', 'jpeg'), 'jpg');
      }
      if (b.length >= 4 && b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) {
        return (MediaType('image', 'png'), 'png');
      }
      if (b.length >= 12 &&
          b[0] == 0x52 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x46 &&
          b[8] == 0x57 && b[9] == 0x45 && b[10] == 0x42 && b[11] == 0x50) {
        return (MediaType('image', 'webp'), 'webp');
      }
    } finally {
      await raf.close();
    }
    return (MediaType('image', 'jpeg'), 'jpg');
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
      final (imageType, imageExt) = await _imageType(image);
      final request = http.MultipartRequest('POST', Uri.parse(_base))
        ..headers.addAll(await _headers())
        ..fields['title'] = title
        ..fields['description'] = description
        ..fields['category'] = category
        ..fields['latitude'] = latitude.toString()
        ..fields['longitude'] = longitude.toString()
        ..fields['address'] = address
        ..files.add(await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: imageType,
          filename: 'reporte.$imageExt',
        ));

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

  /// Últimas noticias ciudadanas aprobadas (como contenido), para Destacados.
  Future<List<ContentItem>> getFeaturedNews({int limit = 2}) {
    return _guard(() async {
      final res = await http
          .get(Uri.parse('$_base/featured?limit=$limit'), headers: await _headers())
          .timeout(_timeout);
      final body = _decode(res);
      final data = body['data'];
      if (data is! List) return <ContentItem>[];
      return data
          .whereType<Map>()
          .map((e) => ContentItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });
  }

  Future<void> approve(String id, {String? title, String? description, String? category}) {
    return _guard(() async {
      final res = await http
          .put(
            Uri.parse('$_base/$id/approve'),
            headers: await _headers(json: true),
            body: jsonEncode({
              'title': ?title,
              'description': ?description,
              'category': ?category,
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