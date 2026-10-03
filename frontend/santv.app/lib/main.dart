import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:http/http.dart' as http;

import 'pages/auth_screen.dart';
import 'pages/home.dart';
import 'pages/verify_code_screen.dart';
import 'services/auth_service.dart';
import 'services/settings_service.dart'; // NUEVO

/// IP de tu PC en la red WiFi (opcional, para el teléfono sin cable).
/// Cámbiala si tu IP cambia: ejecuta `ipconfig` y copia la IPv4.
const String kLanUrl = 'http://192.168.1.X:3000';

/// Direcciones que se prueban en orden. La primera que responda se usa.
const List<String> kCandidateUrls = [
  'http://localhost:3000', // PC/Chrome, o móvil con `adb reverse`
  'http://10.0.2.2:3000', // emulador de Android sin adb reverse
  kLanUrl, // teléfono físico por WiFi
];

/// URL que se usa si ninguna responde (por ejemplo, backend apagado).
/// En Android apunta al localhost de la PC; en el resto, a localhost.
String defaultBaseUrl() {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000';
  }
  return 'http://localhost:3000';
}

/// Prueba cada dirección y devuelve la primera donde el backend responda.
Future<String> resolveBaseUrl() async {
  for (final url in kCandidateUrls) {
    try {
      // Cualquier respuesta (200, 401, 404) significa que el servidor existe.
      await http
          .get(Uri.parse('$url/api/content'))
          .timeout(const Duration(seconds: 2));
      return url;
    } catch (_) {
      // Sigue con la siguiente.
    }
  }
  return defaultBaseUrl();
}

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();

  // Mantiene el splash nativo hasta saber a qué pantalla ir.
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  // NUEVO: carga el tamaño de letra guardado antes de dibujar la app.
  await SettingsService.init();

  String initialRoute = '/login';

  final baseUrl = await resolveBaseUrl();
  debugPrint('Backend en: $baseUrl');
  final authService = AuthService(baseUrl: baseUrl);

  try {
    // getProfile() devuelve null si no hay token, si el token ya no es
    // válido o si el backend no responde en 8 segundos.
    final user = await authService.getProfile();
    if (user != null) {
      initialRoute = '/home';
    }
  } catch (e) {
    debugPrint('Error validando la sesión al arrancar: $e');
  } finally {
    // Siempre se quita el splash, pase lo que pase.
    FlutterNativeSplash.remove();
  }

  runApp(SanTvApp(authService: authService, initialRoute: initialRoute));
}

class SanTvApp extends StatelessWidget {
  const SanTvApp({
    super.key,
    required this.authService,
    required this.initialRoute,
  });

  final AuthService authService;
  final String initialRoute;

  static const Color _neonGreen = Color(0xFF39FF14);
  static const Color _background = Color(0xFF0B0B0B);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAN TV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _background,
        colorScheme: const ColorScheme.dark(primary: _neonGreen),
        useMaterial3: true,
      ),
      // NUEVO: aplica el tamaño de letra elegido a TODA la app.
      builder: (context, child) {
        return ValueListenableBuilder<double>(
          valueListenable: SettingsService.textScale,
          builder: (context, scale, _) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
              ),
              child: child!,
            );
          },
        );
      },
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => AuthScreen(
              authService: authService,
              onLoggedIn: () {
                Navigator.of(context).pushReplacementNamed('/home');
              },
              onRegistered: (email) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VerifyCodeScreen(
                      authService: authService,
                      email: email,
                      onVerified: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/home',
                          (route) => false,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
        '/home': (context) => Home(authService: authService),
      },
    );
  }
}