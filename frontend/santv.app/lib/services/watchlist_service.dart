import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/content.dart';

/// Contadores del perfil.
class WatchStats {
  const WatchStats({required this.favorites, required this.watched});

  final int favorites;
  final int watched;
}

/// Mi Lista (guardados), historial de vistos y contadores del perfil.
/// Todas las llamadas requieren sesión activa.
class WatchlistService {
  WatchlistService({required this.authService});

  final AuthService authService;

  String get _base => '${authService.baseUrl}/api/watchlist';

  Future<Map<String, String>?> _headers() async {
    final token = await authService.getToken();
    if (token == null || token.isEmpty) return null;
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// IDs de los contenidos guardados (para pintar el botón en las tarjetas).
  Future<Set<String>> obtenerIdsGuardados() async {
    try {
      final headers = await _headers();
      if (headers == null) return {};

      final response = await http.get(Uri.parse('$_base/ids'), headers: headers);
      if (response.statusCode != 200) return {};

      final body = jsonDecode(response.body);
      if (body is Map && body['data'] is List) {
        return (body['data'] as List).map((e) => e.toString()).toSet();
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  /// Contenido guardado en Mi Lista (más reciente primero).
  Future<List<ContentItem>> obtenerMiLista() async {
    try {
      final headers = await _headers();
      if (headers == null) return [];

      final response = await http.get(Uri.parse(_base), headers: headers);
      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body);
      if (body is Map && body['data'] is List) {
        return (body['data'] as List)
            .map((e) => ContentItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Guarda un contenido en Mi Lista. Devuelve true si salió bien.
  Future<bool> agregar(String contentId) async {
    try {
      final headers = await _headers();
      if (headers == null) return false;

      final response = await http.post(
        Uri.parse('$_base/$contentId'),
        headers: headers,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  /// Quita un contenido de Mi Lista. Devuelve true si salió bien.
  Future<bool> quitar(String contentId) async {
    try {
      final headers = await _headers();
      if (headers == null) return false;

      final response = await http.delete(
        Uri.parse('$_base/$contentId'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Registra que el usuario vio el video: lo guarda en su historial y suma
  /// una vista pública solo la primera vez. Devuelve las vistas totales
  /// del video, o null si falló.
  Future<int?> registrarVisto(String contentId) async {
    try {
      final headers = await _headers();
      if (headers == null) {
        debugPrint('registrarVisto: NO hay token (sesión no encontrada)');
        return null;
      }

      final url = Uri.parse('$_base/viewed/$contentId');
      debugPrint('registrarVisto: POST $url');
      final response = await http.post(url, headers: headers);
      debugPrint(
        'registrarVisto: status ${response.statusCode} body ${response.body}',
      );
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body);
      if (body is Map && body['data'] is Map) {
        final views = body['data']['views'];
        if (views is num) return views.toInt();
      }
      return null;
    } catch (e) {
      debugPrint('registrarVisto: ERROR $e');
      return null;
    }
  }

  /// Contadores reales del perfil (Favoritos y Vistos).
  Future<WatchStats?> obtenerStats() async {
    try {
      final headers = await _headers();
      if (headers == null) return null;

      final response = await http.get(
        Uri.parse('$_base/stats'),
        headers: headers,
      );
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body);
      if (body is Map && body['data'] is Map) {
        final data = body['data'] as Map;
        return WatchStats(
          favorites: (data['favorites'] as num?)?.toInt() ?? 0,
          watched: (data['watched'] as num?)?.toInt() ?? 0,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}