import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/ad_order.dart';
import 'auth_service.dart';

typedef OrderResult = ({AdOrder? order, String? error});

/// Llamadas a /api/ad-orders (solicitudes de pauta y su pago).
class AdOrderService {
  AdOrderService({required this.authService});

  final AuthService authService;

  Uri _url([String path = '']) =>
      Uri.parse('${authService.baseUrl}/api/ad-orders$path');

  Future<Map<String, String>> _headers() async {
    final token = await authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  String _error(http.Response r, String porDefecto) {
    try {
      final body = jsonDecode(r.body);
      return body['message']?.toString() ?? porDefecto;
    } catch (_) {
      return porDefecto;
    }
  }

  /// Crea la solicitud. Devuelve la orden o el mensaje de error.
  Future<OrderResult> crear({
    required String company,
    required String contactName,
    required String contactPhone,
    required String planName,
    required double amount,
    required String paymentMethod,
    String notes = '',
  }) async {
    try {
      final r = await http.post(
        _url(),
        headers: await _headers(),
        body: jsonEncode({
          'company': company,
          'contactName': contactName,
          'contactPhone': contactPhone,
          'planName': planName,
          'amount': amount,
          'paymentMethod': paymentMethod,
          'notes': notes,
        }),
      );
      if (r.statusCode == 201 || r.statusCode == 200) {
        final data = jsonDecode(r.body)['data'] as Map<String, dynamic>;
        return (order: AdOrder.fromJson(data), error: null);
      }
      return (order: null, error: _error(r, 'No se pudo crear la solicitud'));
    } catch (_) {
      return (order: null, error: 'No se pudo conectar con el servidor');
    }
  }

  /// Sube la captura del pago. Devuelve null si salió bien, o el error.
  Future<String?> subirComprobante(String id, File imagen) async {
    try {
      final headers = await _headers();
      final request = http.MultipartRequest('POST', _url('/$id/receipt'))
        ..headers['Authorization'] = headers['Authorization']!
        ..files.add(await http.MultipartFile.fromPath('comprobante', imagen.path));

      final streamed = await request.send().timeout(const Duration(minutes: 2));
      final r = await http.Response.fromStream(streamed);
      if (r.statusCode == 200 || r.statusCode == 201) return null;
      return _error(r, 'No se pudo subir el comprobante (${r.statusCode})');
    } catch (_) {
      return 'No se pudo conectar con el servidor';
    }
  }

  Future<List<AdOrder>> _lista(Uri url) async {
    final r = await http.get(url, headers: await _headers());
    if (r.statusCode != 200) {
      throw Exception(_error(r, 'No se pudieron cargar las solicitudes'));
    }
    final body = jsonDecode(r.body);
    final data = body is Map ? body['data'] : null;
    if (data is! List) return [];
    return data
        .map((e) => AdOrder.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Solicitudes del usuario logueado.
  Future<List<AdOrder>> misSolicitudes() => _lista(_url('/mine'));

  /// ADMIN: todas las solicitudes.
  Future<List<AdOrder>> todas() => _lista(_url());

  Future<String?> _put(String path, Map<String, dynamic>? body, String porDefecto) async {
    try {
      final r = await http.put(
        _url(path),
        headers: await _headers(),
        body: jsonEncode(body ?? {}),
      );
      return r.statusCode == 200 ? null : _error(r, porDefecto);
    } catch (_) {
      return 'No se pudo conectar con el servidor';
    }
  }

  /// ADMIN: valida el pago. Devuelve null si salió bien, o el error.
  Future<String?> validar(String id) =>
      _put('/$id/validate', null, 'No se pudo validar el pago');

  /// ADMIN: invalida el pago (cancela la solicitud).
  Future<String?> invalidar(String id, String motivo) =>
      _put('/$id/invalidate', {'reason': motivo}, 'No se pudo invalidar el pago');
}
