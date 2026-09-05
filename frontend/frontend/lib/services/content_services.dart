import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ContentUploadResult {
  ContentUploadResult({required this.success, this.errorMessage});

  final bool success;
  final String? errorMessage;
}

class ContentService {
  ContentService({required this.authService});

  final AuthService authService;

  Uri get _contentUrl => Uri.parse('${authService.baseUrl}/api/content');

  /// Crea un nuevo Content subiendo el archivo de video a Cloudinary
  /// a través del backend (multipart/form-data).
  ///
  /// [genres] se envía como texto separado por comas (ej: "Acción, Drama").
  Future<ContentUploadResult> subirVideo({
    required String title,
    required String description,
    required String type, // movie | series | documentary
    required File videoFile,
    String genres = '',
    String thumbnailUrl = '',
    int? duration, // minutos
    int? releaseYear,
    bool isPremium = false,
  }) async {
    try {
      final token = await authService.getToken();
      if (token == null || token.isEmpty) {
        return ContentUploadResult(
          success: false,
          errorMessage: 'No hay sesión activa. Vuelve a iniciar sesión.',
        );
      }

      final request = http.MultipartRequest('POST', _contentUrl)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['title'] = title
        ..fields['description'] = description
        ..fields['type'] = type
        ..fields['genres'] = genres
        ..fields['thumbnailUrl'] = thumbnailUrl
        ..fields['isPremium'] = isPremium.toString();

      if (duration != null) request.fields['duration'] = duration.toString();
      if (releaseYear != null) {
        request.fields['releaseYear'] = releaseYear.toString();
      }

      request.files.add(
        await http.MultipartFile.fromPath('video', videoFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ContentUploadResult(success: true);
      }

      String mensajeError = 'No se pudo subir el video (${response.statusCode}).';
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data['message'] != null) {
          mensajeError = data['message'];
        }
      } catch (_) {
        // el body no era JSON, se deja el mensaje genérico
      }

      return ContentUploadResult(success: false, errorMessage: mensajeError);
    } catch (e) {
      return ContentUploadResult(
        success: false,
        errorMessage: 'Error de conexión con el servidor. Verifica tu red.',
      );
    }
  }
}