import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/comment.dart';
import 'auth_service.dart';

/// Una página de comentarios traída del backend.
class CommentsPage {
  const CommentsPage({
    required this.items,
    required this.total,
    required this.hasMore,
  });

  final List<CommentItem> items;
  final int total;
  final bool hasMore;
}

/// Resultado de crear o borrar un comentario.
class CommentResult {
  const CommentResult({
    required this.success,
    this.errorMessage,
    this.comment,
  });

  final bool success;
  final String? errorMessage;
  final CommentItem? comment;
}

class CommentService {
  CommentService({required this.authService});

  final AuthService authService;

  static const _timeout = Duration(seconds: 15);

  Uri _url(String contentId, [String extra = '']) => Uri.parse(
        '${authService.baseUrl}/api/content/$contentId/comments$extra',
      );

  /// Trae los comentarios del video, del más nuevo al más viejo.
  /// Devuelve null si falla la conexión.
  Future<CommentsPage?> getComments(
    String contentId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final uri = _url(contentId).replace(
        queryParameters: {'page': '$page', 'limit': '$limit'},
      );
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body);
      if (body is Map && body['success'] == true && body['data'] is List) {
        final items = (body['data'] as List)
            .map((e) => CommentItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        return CommentsPage(
          items: items,
          total: (body['total'] as num?)?.toInt() ?? items.length,
          hasMore: body['hasMore'] == true,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Publica un comentario nuevo (requiere sesión).
  Future<CommentResult> addComment(String contentId, String text) async {
    try {
      final token = await authService.getToken();
      if (token == null || token.isEmpty) {
        return const CommentResult(
          success: false,
          errorMessage: 'Inicia sesión para comentar',
        );
      }

      final response = await http
          .post(
            _url(contentId),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'text': text}),
          )
          .timeout(_timeout);

      final body = jsonDecode(response.body);

      if ((response.statusCode == 201 || response.statusCode == 200) &&
          body is Map &&
          body['success'] == true &&
          body['data'] is Map) {
        return CommentResult(
          success: true,
          comment: CommentItem.fromJson(
            Map<String, dynamic>.from(body['data'] as Map),
          ),
        );
      }

      return CommentResult(
        success: false,
        errorMessage: (body is Map ? body['message']?.toString() : null) ??
            'No se pudo publicar el comentario',
      );
    } catch (_) {
      return const CommentResult(
        success: false,
        errorMessage: 'No se pudo conectar con el servidor',
      );
    }
  }

  /// Borra un comentario (el dueño o un admin).
  Future<CommentResult> deleteComment(
    String contentId,
    String commentId,
  ) async {
    try {
      final token = await authService.getToken();
      if (token == null || token.isEmpty) {
        return const CommentResult(
          success: false,
          errorMessage: 'No has iniciado sesión',
        );
      }

      final response = await http.delete(
        _url(contentId, '/$commentId'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return const CommentResult(success: true);
      }

      String message = 'No se pudo borrar el comentario';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['message'] != null) {
          message = body['message'].toString();
        }
      } catch (_) {}

      return CommentResult(success: false, errorMessage: message);
    } catch (_) {
      return const CommentResult(
        success: false,
        errorMessage: 'No se pudo conectar con el servidor',
      );
    }
  }
}