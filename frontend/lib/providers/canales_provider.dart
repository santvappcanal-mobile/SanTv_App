import 'package:flutter/material.dart';
import '../models/canal.dart';
import '../services/api_service.dart';

class CanalesProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<Canal> canales = [];
  bool cargando = false;
  String? error;

  Future<void> cargarCanales() async {
    cargando = true;
    error = null;
    notifyListeners();
    try {
      canales = await _api.getCanales();
    } catch (e) {
      error = e.toString();
    }
    cargando = false;
    notifyListeners();
  }
}