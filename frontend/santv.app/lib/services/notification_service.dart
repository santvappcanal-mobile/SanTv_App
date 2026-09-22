import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/app_notification.dart';
import 'auth_service.dart';

class NotificationsResult {
  final bool success;
  final String? errorMessage;
  final List<AppNotification> notifications;
  final int unreadCount;

  const NotificationsResult({
    required this.success,
    this.errorMessage,
    this.notifications = const [],
    this.unreadCount = 0,
  });
}

class NotificationService {
  NotificationService({required this.authService});

  final AuthService authService;

  Uri _endpoint(String path) =>
      Uri.parse('${authService.baseUrl}/api/notifications$path');

  Future<Map<String, String>?> _headers() async {
    final token = await authService.getToken();
    if (token == null) return null;
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<NotificationsResult> getNotifications() async {
    try {
      final headers = await _headers();
      if (headers == null) {
        return const NotificationsResult(
          success: false,
          errorMessage: 'No has iniciado sesión',
        );
      }

      final response = await http.get(_endpoint(''), headers: headers);
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        final list = (body['data'] as List<dynamic>)
            .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
            .toList();
        return NotificationsResult(
          success: true,
          notifications: list,
          unreadCount: (body['unreadCount'] as num?)?.toInt() ?? 0,
        );
      }

      return NotificationsResult(
        success: false,
        errorMessage: body['message']?.toString() ?? 'No se pudieron cargar',
      );
    } catch (e) {
      return NotificationsResult(
        success: false,
        errorMessage: 'No se pudo conectar con el servidor: $e',
      );
    }
  }

  Future<bool> markAsRead(String id) async {
    final headers = await _headers();
    if (headers == null) return false;
    final response = await http.put(_endpoint('/$id/read'), headers: headers);
    return response.statusCode == 200;
  }

  Future<bool> markAllAsRead() async {
    final headers = await _headers();
    if (headers == null) return false;
    final response = await http.put(_endpoint('/read-all'), headers: headers);
    return response.statusCode == 200;
  }

  Future<bool> deleteNotification(String id) async {
    final headers = await _headers();
    if (headers == null) return false;
    final response = await http.delete(_endpoint('/$id'), headers: headers);
    return response.statusCode == 200;
  }
}