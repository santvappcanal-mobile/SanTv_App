import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/canal.dart';

class ApiService {
  // Cambia esto por la IP/puerto real de tu backend.
  // En emulador Android usa 10.0.2.2 en vez de localhost.
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  Future<List<Canal>> getCanales() async {
    final response = await http.get(Uri.parse('$baseUrl/canales'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((c) => Canal.fromJson(c)).toList();
    } else {
      throw Exception('Error al cargar canales: ${response.statusCode}');
    }
  }
}