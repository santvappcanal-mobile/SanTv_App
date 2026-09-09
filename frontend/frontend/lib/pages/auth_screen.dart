import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/auth/auth_header.dart';
import '../widgets/auth/auth_footer.dart';
import '../widgets/auth/auth_tab_selector.dart';
import 'login_screen.dart';
import 'register_screen.dart';

/// Pantalla única (fondo + tarjeta + pestañas) que muestra
/// [LoginScreen] o [RegisterScreen] según la pestaña activa.
/// Cada uno mantiene su propio código y estado; esta pantalla
/// solo los aloja.
class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.authService,
    this.onLoggedIn,
    this.onRegistered,
  });

  final AuthService authService;
  final void Function()? onLoggedIn;
  final void Function(String email)? onRegistered;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int _tabIndex = 0; // 0 = login, 1 = registro

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthTabSelector(
                          selectedIndex: _tabIndex,
                          onTabSelected: (index) =>
                              setState(() => _tabIndex = index),
                        ),
                        const SizedBox(height: 20),
                        // Aquí se embebe cada pantalla por separado:
                        _tabIndex == 0
                            ? LoginScreen(
                                authService: widget.authService,
                                onLoggedIn: widget.onLoggedIn,
                              )
                            : RegisterScreen(
                                authService: widget.authService,
                                onRegistered: widget.onRegistered,
                                onLoggedIn: widget.onLoggedIn,
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const AuthFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
