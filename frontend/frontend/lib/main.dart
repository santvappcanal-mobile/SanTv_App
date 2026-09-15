import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';
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
  State createState() => _SanTvAppState();
}

class _SanTvAppState extends State {
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
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
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
        '/home': (context) => Home(authService: authService),
      },
    );
  }
}