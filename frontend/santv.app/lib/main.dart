import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'pages/home.dart';
import 'pages/auth_screen.dart';
import 'pages/verify_code_screen.dart';
import 'services/auth_service.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const SanTvApp());
}

class SanTvApp extends StatefulWidget {
  const SanTvApp({super.key});

  @override
  State<SanTvApp> createState() => _SanTvAppState();
}

class _SanTvAppState extends State<SanTvApp> {
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
        '/': (context) => _Bootstrap(authService: authService),
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

/// No dibuja nada propio: mientras se resuelve, el splash nativo
/// (pantalla negra con el logo) sigue tapando la UI. Cuando ya
/// sabemos a dónde ir, lo quitamos y navegamos, todo en un solo paso.
class _Bootstrap extends StatefulWidget {
  const _Bootstrap({required this.authService});

  final AuthService authService;

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final token = await _storage.read(key: _tokenKey);

    FlutterNativeSplash.remove();

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      (token != null && token.isNotEmpty) ? '/home' : '/login',
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}