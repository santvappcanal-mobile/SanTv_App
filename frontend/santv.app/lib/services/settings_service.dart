import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias locales de la app (se guardan en el dispositivo).
class SettingsService {
  static const _autoplayKey = 'autoplay';

  static Future<bool> getAutoplay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoplayKey) ?? true;
  }

  static Future<void> setAutoplay(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoplayKey, value);
  }
}
