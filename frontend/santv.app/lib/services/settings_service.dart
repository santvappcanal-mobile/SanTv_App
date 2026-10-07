import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias locales de la app (se guardan en el dispositivo).
class SettingsService {
  static const _autoplayKey = 'autoplay';
  static const _textScaleKey = 'text_scale_index';

  // ── Tamaño de letra ──
  /// Factores de escala, del más pequeño al más grande.
  static const List<double> textScaleSteps = [0.8, 0.9, 1.0, 1.15, 1.3];
  static const List<String> textScaleLabels = [
    'Muy pequeño',
    'Pequeño',
    'Normal',
    'Grande',
    'Muy grande',
  ];
  static const int _defaultScaleIndex = 2; // Normal

  /// Índice actual (0..4). Se carga en [init].
  static int textScaleIndex = _defaultScaleIndex;

  /// Escala actual. main.dart la escucha para reescalar toda la app.
  static final ValueNotifier<double> textScale = ValueNotifier<double>(1.0);

  /// Llamar una vez en main(), antes de runApp().
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_textScaleKey) ?? _defaultScaleIndex;
    textScaleIndex = saved.clamp(0, textScaleSteps.length - 1);
    textScale.value = textScaleSteps[textScaleIndex];
  }

  static Future<void> setTextScaleIndex(int index) async {
    final i = index.clamp(0, textScaleSteps.length - 1);
    textScaleIndex = i;
    textScale.value = textScaleSteps[i];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_textScaleKey, i);
  }

  // ── Reproducción automática ──
  static Future<bool> getAutoplay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoplayKey) ?? true;
  }

  static Future<void> setAutoplay(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoplayKey, value);
  }
}