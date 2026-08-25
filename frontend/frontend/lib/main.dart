import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'pages/login_screen.dart'; // Verifica que el nombre del archivo coincida con la ubicación de tu Login

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
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const Home(),
      },
    );
  }
}