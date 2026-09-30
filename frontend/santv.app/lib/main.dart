import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'pages/auth_screen.dart';
import 'pages/home.dart';
import 'pages/verify_code_screen.dart';
import 'services/auth_service.dart';

/// URL del backend. 10.0.2.2 = localhost de tu PC visto desde el
/// emulador de Android.
const String kBaseUrl = 'http://10.0.2.2:3000';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();

  // Mantiene el splash nativo hasta saber a qué pantalla ir.
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  final authService = AuthService(baseUrl: kBaseUrl);
  String initialRoute = '/login';

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