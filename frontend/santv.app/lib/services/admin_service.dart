import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/admin_stats.dart';
import '../models/admin_user.dart'; // NUEVO

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

// Resultado de traer la lista completa de videos
class AdminContentListResult {
  final bool success;
  final List<TopContentItem> items;
  final String? errorMessage;

  const AdminContentListResult({
    required this.success,
    this.items = const [],
    this.errorMessage,
  });
}

// NUEVO: resultado de traer la lista de usuarios
class AdminUsersResult {
  final bool success;
  final List<AdminUser> users;
  final String? errorMessage;

  const AdminUsersResult({
    required this.success,
    this.users = const [],
    this.errorMessage,
  });
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

  /// Trae todo el contenido (activo o no) para la lista del dashboard.
  /// Usa GET /api/content/admin?limit=1000 (protegido: editor / admin).
  Future<AdminContentListResult> getAllContent({int limit = 1000}) async {
    try {
      final token = await authService.getToken();
      if (token == null || token.isEmpty) {
        return const AdminContentListResult(
          success: false,
          errorMessage: 'No hay sesión activa. Vuelve a iniciar sesión.',
        );
      }

      final uri = Uri.parse(
        '${authService.baseUrl}/api/content/admin',
      ).replace(queryParameters: {'limit': '$limit'});

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 &&
          body['success'] == true &&
          body['data'] is List) {
        final items = (body['data'] as List)
            .map((e) => TopContentItem.fromJson(e as Map<String, dynamic>))
            .toList();
        return AdminContentListResult(success: true, items: items);
      }

      return AdminContentListResult(
        success: false,
        errorMessage:
            body['message']?.toString() ?? 'No se pudo cargar el contenido.',
      );
    } catch (e) {
      return const AdminContentListResult(
        success: false,
        errorMessage: 'Error de conexión con el servidor. Verifica tu red.',
      );
    }
  }

  /// NUEVO: trae todos los usuarios registrados.
  /// Usa GET /api/users?limit=1000 (protegido: solo admin).
  Future<AdminUsersResult> getAllUsers({int limit = 1000}) async {
    try {
      final token = await authService.getToken();
      if (token == null || token.isEmpty) {
        return const AdminUsersResult(
          success: false,
          errorMessage: 'No hay sesión activa. Vuelve a iniciar sesión.',
        );
      }

      final uri = Uri.parse(
        '${authService.baseUrl}/api/users',
      ).replace(queryParameters: {'limit': '$limit'});

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 &&
          body['success'] == true &&
          body['data'] is List) {
        final users = (body['data'] as List)
            .map((e) => AdminUser.fromJson(e as Map<String, dynamic>))
            .toList();
        return AdminUsersResult(success: true, users: users);
      }

      return AdminUsersResult(
        success: false,
        errorMessage:
            body['message']?.toString() ??
            'No se pudieron cargar los usuarios.',
      );
    } catch (e) {
      return const AdminUsersResult(
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