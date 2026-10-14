import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_reply.dart';
import 'auth_service.dart';

class ChatService {
  ChatService({required this.authService});

  final AuthService authService;

  Uri get _chatUrl => Uri.parse('${authService.baseUrl}/api/chat');

  /// Envía el mensaje al asistente y devuelve su texto junto con las
  /// tarjetas (video, referencias, documento) si el usuario las pidió.
  Future<ChatReply> enviarMensaje(String mensaje) async {
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

        final texto =
            (data['respuesta'] ?? 'No se recibió respuesta del asistente.')
                .toString();

        final raw = data['adjuntos'];
        final adjuntos = raw is List
            ? raw
                .whereType<Map>()
                .map((e) => ChatAttachment.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : <ChatAttachment>[];

        return ChatReply(texto: texto, adjuntos: adjuntos);
      } else {
        return ChatReply(
          texto:
              'El asistente virtual no está disponible ahora mismo (Error ${response.statusCode}).',
        );
      }
    } catch (e) {
      return const ChatReply(
        texto: 'Error de conexión con el servidor. Verifica tu red o la URL base.',
      );
    }
  }
}