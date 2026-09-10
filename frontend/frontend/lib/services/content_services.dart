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
  Uri get _uploadVideoUrl =>
      Uri.parse('${authService.baseUrl}/api/uploads/video');

  /// Paso 1: sube el archivo de video a Cloudinary a través del backend.
  /// Devuelve el mapa {url, publicId} si tiene éxito, o null si falla.
  Future<Map<String, String>?> _subirArchivoVideo(
    File videoFile,
    String token,
  ) async {
    final request = http.MultipartRequest('POST', _uploadVideoUrl)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', videoFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      return null;
    }

    final data = jsonDecode(response.body);
    if (data is Map && data['url'] != null) {
      return {
        'url': data['url'].toString(),
        'publicId': data['publicId']?.toString() ?? '',
      };
    }
    return null;
  }

  /// Crea un nuevo Content: primero sube el video a Cloudinary,
  /// luego crea el documento con la URL resultante.
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

      // --- Paso 1: subir el archivo de video ---
      final videoData = await _subirArchivoVideo(videoFile, token);
      if (videoData == null) {
        return ContentUploadResult(
          success: false,
          errorMessage: 'No se pudo subir el archivo de video.',
        );
      }

      // --- Paso 2: crear el contenido con la URL obtenida ---
      final genresList = genres
          .split(',')
          .map((g) => g.trim())
          .where((g) => g.isNotEmpty)
          .toList();

      final response = await http.post(
        _contentUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'type': type,
          'genres': genresList,
          'videoUrl': videoData['url'],
          'videoPublicId': videoData['publicId'],
          if (thumbnailUrl.isNotEmpty) 'thumbnailUrl': thumbnailUrl,
          if (duration != null) 'duration': duration,
          if (releaseYear != null) 'releaseYear': releaseYear,
          'isPremium': isPremium,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ContentUploadResult(success: true);
      }

      String mensajeError =
          'No se pudo crear el contenido (${response.statusCode}).';
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
