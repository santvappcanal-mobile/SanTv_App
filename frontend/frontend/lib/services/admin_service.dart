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
}
