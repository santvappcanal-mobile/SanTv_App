import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

// Ocultamos AdDocumentItem de ad.dart e importamos la versión oficial
import '../models/ad.dart' hide AdDocumentItem;
import '../models/ad_document_item.dart';

class AdService {
  AdService({required this.authService});

  final AuthService authService;

  Uri get _adsForContentUrl =>
      Uri.parse('${authService.baseUrl}/api/ads/for-content');

  Uri _impressionUrl(String id) =>
      Uri.parse('${authService.baseUrl}/api/ads/$id/impression');

  Uri _clickUrl(String id) =>
      Uri.parse('${authService.baseUrl}/api/ads/$id/click');

  Uri get _adDocumentsUrl =>
      Uri.parse('${authService.baseUrl}/api/ad-documents');

  Uri _adDocumentByIdUrl(String id) =>
      Uri.parse('${authService.baseUrl}/api/ad-documents/$id');

  Uri get _uploadDocumentUrl =>
      Uri.parse('${authService.baseUrl}/api/uploads/document');

  /// Trae todos los anuncios activos vigentes (sin filtrar por tipo).
  /// No requiere sesión activa, es un endpoint público.
  Future<List<AdItem>> obtenerAdsActivos() async {
    try {
      final response = await http.get(_adsForContentUrl);

      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body);
      if (body is Map && body['success'] == true && body['data'] is List) {
        return (body['data'] as List)
            .map((e) => AdItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Registra que el anuncio fue mostrado (no bloquea la UI si falla).
  Future<void> registrarImpresion(String adId) async {
    try {
      await http.put(_impressionUrl(adId));
    } catch (_) {}
  }

  /// Registra que el usuario tocó el anuncio.
  Future<void> registrarClic(String adId) async {
    try {
      await http.put(_clickUrl(adId));
    } catch (_) {}
  }

  /// Trae todos los documentos de publicidad (PDFs). Público, no
  /// requiere sesión activa.
  Future<List<AdDocumentItem>> getDocuments() async {
    final response = await http.get(_adDocumentsUrl);

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar los documentos');
    }

    final body = jsonDecode(response.body);
    if (body is Map && body['success'] == true && body['data'] is List) {
      return (body['data'] as List)
          .map((e) => AdDocumentItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Sube un PDF a Cloudinary y crea el registro del documento.
  /// Requiere sesión de editor/admin. Devuelve true si todo salió bien.
  Future<bool> uploadDocument(File pdfFile, String title) async {
    try {
      final token = await authService.getToken();
      if (token == null || token.isEmpty) return false;

      // Paso 1: subir el PDF a Cloudinary
      final uploadRequest = http.MultipartRequest('POST', _uploadDocumentUrl)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('file', pdfFile.path));

      final uploadStreamed = await uploadRequest.send();
      final uploadResponse = await http.Response.fromStream(uploadStreamed);

      if (uploadResponse.statusCode != 200 &&
          uploadResponse.statusCode != 201) {
        return false;
      }

      final uploadData = jsonDecode(uploadResponse.body);
      final mediaUrl = uploadData['url']?.toString();
      final publicId = uploadData['publicId']?.toString();

      if (mediaUrl == null) return false;

      // Paso 2: crear el registro del documento
      final createResponse = await http.post(
        _adDocumentsUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'mediaUrl': mediaUrl,
          'publicId': publicId,
        }),
      );

      return createResponse.statusCode == 200 ||
          createResponse.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  /// Elimina un documento (y su archivo en Cloudinary, del lado del backend).
  Future<bool> deleteDocument(String id) async {
    try {
      final token = await authService.getToken();
      if (token == null || token.isEmpty) return false;

      final response = await http.delete(
        _adDocumentByIdUrl(id),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
