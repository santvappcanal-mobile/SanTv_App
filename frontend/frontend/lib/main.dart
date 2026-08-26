import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'pages/auth_screen.dart';
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
    // Instancia única del servicio de autenticación. Cambia baseUrl
    // por la URL real de tu backend "SanTv-App" cuando conectes el
    // AuthService real (por ahora usa la versión simulada).
    final authService = AuthService(baseUrl: 'https://tu-api.com');

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
                // TODO: cuando tengas la pantalla de verificación de
                // código, navega aquí pasando el email, ej:
                // Navigator.pushNamed(context, '/verify', arguments: email);
              },
            ),
        '/home': (context) => const Home(),
      },
    );
  }
}