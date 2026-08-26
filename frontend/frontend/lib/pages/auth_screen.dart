import 'package:flutter/material.dart';
import '../services/auth_service.dart';
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
                  // Logo (reemplaza al ícono + texto "SAN TV")
                  Center(
                    child: Image.asset(
                      'assets/img/original.png',
                      height: 110,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tu plataforma de streaming favorita',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
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
                        _buildTabSelector(),
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
                  const Text(
                    '© 2026 SAN TV. Todos los derechos reservados.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildTabButton('Iniciar Sesión', 0),
          _buildTabButton('Registrarse', 1),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final bool selected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.black : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}