import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ChatService {
  ChatService({required this.authService});

  final AuthService authService;

  Uri get _chatUrl => Uri.parse('${authService.baseUrl}/api/chat');

  Future<String> enviarMensaje(String mensaje) async {
    try {
      final response = await http.post(
        _chatUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'mensaje': mensaje}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['respuesta'] ?? 'No se recibió respuesta del asistente.';
      } else {
        return 'El asistente virtual no está disponible ahora mismo (Error ${response.statusCode}).';
      }
    } catch (e) {
      return 'Error de conexión con el servidor. Verifica tu red o la URL base.';
    }
  }
}