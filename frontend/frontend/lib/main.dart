import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'pages/auth_screen.dart';
import 'pages/verify_code_screen.dart';
import 'services/auth_service.dart';

void main() async {
  // Asegura la inicialización de widgets antes de llamar servicios asíncronos
  WidgetsFlutterBinding.ensureInitialized();

  // Si utilizas Firebase u otro SDK backend, se inicializa aquí:
  // await Firebase.initializeApp();

  runApp(const SanTvApp());
}

class SanTvApp extends StatelessWidget {
  const SanTvApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Instancia única del servicio de autenticación real, conectada
    // al backend de Node/Express.
    // - Emulador Android: usa 10.0.2.2 (así el emulador ve tu PC)
    // - Simulador iOS: usa localhost
    // - Dispositivo físico: usa la IP local de tu PC (ej: 192.168.x.x)
    final authService = AuthService(baseUrl: 'http://10.0.2.2:3000');

    return MaterialApp(
      title: 'SAN TV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF39FF14), // Verde neón
        ),
        useMaterial3: true,
      ),
      // Definición del flujo de inicio por rutas
      initialRoute: '/login',
      routes: {
        '/login': (context) => AuthScreen(
              authService: authService,
              onLoggedIn: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              onRegistered: (email) {
                // Registro exitoso -> pantalla de verificación de código
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VerifyCodeScreen(
                      authService: authService,
                      email: email,
                      onVerified: () {
                        // Código correcto -> entra al Home, sin poder
                        // volver atrás a la pantalla de login/registro
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                        );
                      },
                      onCancel: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
            ),
        '/home': (context) => const Home(),
      },
    );
  }
}