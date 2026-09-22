import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/admin_stats.dart';

class AdminStatsResult {
  final bool success;
  final AdminStats? stats;
  final String? errorMessage;

  const AdminStatsResult({
    required this.success,
    this.stats,
    this.errorMessage,
  });
}

class AdminActionResult {
  final bool success;
  final String? errorMessage;

  const AdminActionResult({required this.success, this.errorMessage});
}

class AdminService {
  AdminService({required this.authService});

  final AuthService authService;

  Uri get _statsUrl => Uri.parse('${authService.baseUrl}/api/admin/stats');

  Future<AdminStatsResult> getDashboardStats() async {
    try {
      final token = await authService.getToken();
      if (token == null || token.isEmpty) {
        return const AdminStatsResult(
          success: false,
          errorMessage: 'No hay sesión activa. Vuelve a iniciar sesión.',
        );
      }

      final response = await http.get(
        _statsUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        return AdminStatsResult(
          success: true,
          stats: AdminStats.fromJson(body['data'] as Map<String, dynamic>),
        );
      }

      return AdminStatsResult(
        success: false,
        errorMessage:
            body['message']?.toString() ??
            'No se pudieron cargar las estadísticas.',
      );
    } catch (e) {
      return const AdminStatsResult(
        success: false,
        errorMessage: 'Error de conexión con el servidor. Verifica tu red.',
      );
    }
  }

  /// Edita título y descripción de un contenido.
  /// Usa PUT /api/content/:id (protegido: editor / admin).
  Future<AdminActionResult> updateContent({
    required String id,
    required String title,
    required String description,
  }) async {
    try {
      final token = await authService.getToken();
      if (token == null || token.isEmpty) {
        return const AdminActionResult(
          success: false,
          errorMessage: 'No hay sesión activa. Vuelve a iniciar sesión.',
        );
      }

      final response = await http.put(
        Uri.parse('${authService.baseUrl}/api/content/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'title': title, 'description': description}),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        return const AdminActionResult(success: true);
      }

      return AdminActionResult(
        success: false,
        errorMessage:
            body['message']?.toString() ??
            'No se pudo actualizar el contenido.',
      );
    } catch (e) {
      return const AdminActionResult(
        success: false,
        errorMessage: 'Error de conexión con el servidor. Verifica tu red.',
      );
    }
  }

  /// Elimina un contenido definitivamente.
  /// Usa DELETE /api/content/:id (protegido: editor / admin).
  Future<AdminActionResult> deleteContent(String id) async {
    try {
      final token = await authService.getToken();
      if (token == null || token.isEmpty) {
        return const AdminActionResult(
          success: false,
          errorMessage: 'No hay sesión activa. Vuelve a iniciar sesión.',
        );
      }

      final response = await http.delete(
        Uri.parse('${authService.baseUrl}/api/content/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        return const AdminActionResult(success: true);
      }

      return AdminActionResult(
        success: false,
        errorMessage:
            body['message']?.toString() ?? 'No se pudo eliminar el contenido.',
      );
    } catch (e) {
      return const AdminActionResult(
        success: false,
        errorMessage: 'Error de conexión con el servidor. Verifica tu red.',
      );
    }
  }
}