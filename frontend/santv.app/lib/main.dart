import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:http/http.dart' as http;

import 'services/api_config.dart';
import 'pages/auth_screen.dart';
import 'pages/home.dart';
import 'pages/verify_code_screen.dart';
import 'services/auth_service.dart';
import 'services/push_notification_service.dart';
import 'services/settings_service.dart';

/// Tiempo máximo que se espera a que el backend "despierte".
/// En el plan gratuito de Render, tras un rato sin uso la primera petición
/// puede tardar entre 30 y 60 segundos.
const Duration kWakeUpTimeout = Duration(seconds: 30);

/// Despierta el backend (Render) antes de validar la sesión.
/// Cualquier respuesta significa que el servidor ya está activo.
/// Si falla o se agota el tiempo, la app sigue su arranque normal.
Future<void> _wakeUpBackend(String baseUrl) async {
  try {
    await http.get(Uri.parse('$baseUrl/health')).timeout(kWakeUpTimeout);
  } catch (e) {
    debugPrint('El backend no respondió al despertar: $e');
  }
}

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();

  // Mantiene el splash nativo hasta saber a qué pantalla ir.
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  // Carga el tamaño de letra guardado antes de dibujar la app.
  await SettingsService.init();

  // Prepara Firebase (notificaciones push) sin retrasar el arranque.
  // Si Firebase no está configurado, simplemente se omite.
  unawaited(PushNotificationService.instance.init());

  String initialRoute = '/login';

  final baseUrl = ApiConfig.baseUrl;
  debugPrint('Backend en: $baseUrl');
  final authService = AuthService(baseUrl: baseUrl);

  try {
    // Evita que una sesión válida se pierda solo porque Render estaba dormido.
    await _wakeUpBackend(baseUrl);

    // getProfile() devuelve null si no hay token, si el token ya no es
    // válido o si el backend no responde a tiempo.
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
      // Aplica el tamaño de letra elegido a TODA la app.
      builder: (context, child) {
        return ValueListenableBuilder<double>(
          valueListenable: SettingsService.textScale,
          builder: (context, scale, _) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
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
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/home', (route) => false);
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