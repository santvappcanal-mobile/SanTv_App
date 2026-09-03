import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'pages/auth_screen.dart';
import 'pages/verify_code_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SanTvApp());
}

class SanTvApp extends StatefulWidget {
  const SanTvApp({super.key});

  @override
  State<SanTvApp> createState() => _SanTvAppState();
}

class _SanTvAppState extends State<SanTvApp> {
  // OJO: se movió aquí (fuera de build) para que sea UNA sola instancia
  // durante toda la vida de la app, en vez de crear un AuthService nuevo
  // en cada rebuild del widget.
  late final AuthService authService = AuthService(
    baseUrl: 'http://10.0.2.2:3000',
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAN TV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF39FF14),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => AuthScreen(
              authService: authService,
              onLoggedIn: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              onRegistered: (email) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VerifyCodeScreen(
                      authService: authService,
                      email: email,
                      onVerified: () {
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
        // AHORA le pasamos el authService a Home
        '/home': (context) => Home(authService: authService),
      },
    );
  }
}