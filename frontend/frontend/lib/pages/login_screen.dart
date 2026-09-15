import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/auth/auth_frosted_card.dart';
import '../widgets/auth/auth_form_field.dart';
import '../widgets/auth/auth_submit_button.dart';
import '../widgets/auth/forgot_password_link.dart';
import '../widgets/auth/or_divider.dart';
import '../widgets/auth/google_signin_button.dart';
import 'forgot_password_screen.dart';

/// Formulario de inicio de sesión con estilo glassmorfismo. Se usa
/// embebido dentro de [AuthScreen] (pages/auth_screen.dart), dentro
/// de la pestaña "Iniciar Sesión". Toda la lógica de login vive
/// aquí, separada del registro.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authService, this.onLoggedIn});

  final AuthService authService;

  /// Se llama cuando el login (o login con Google) fue exitoso.
  final void Function()? onLoggedIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;

  static const Color _neonGreen = Color(0xFF39FF14);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final result = await widget.authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;

      if (result.success) {
        widget.onLoggedIn?.call();
      } else {
        _showError(result.errorMessage ?? 'Credenciales incorrectas');
      }
    } catch (e) {
      if (mounted) _showError('Error al iniciar sesión: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _loading = true);
    try {
      final result = await widget.authService.loginWithGoogle();
      if (!mounted) return;

      if (result.success) {
        widget.onLoggedIn?.call();
      } else {
        _showError(result.errorMessage ?? 'No se pudo continuar con Google.');
      }
    } catch (e) {
      if (mounted) _showError('Error con Google Sign-In: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goToForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ForgotPasswordScreen(authService: widget.authService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Nota: no lleva Scaffold propio porque se embebe dentro de
    // AuthScreen, que ya provee el fondo (idealmente con gradiente
    // o imagen) sobre el que flota esta tarjeta de vidrio.
    return AuthFrostedCard(
      boxShadow: [
        BoxShadow(
          color: _neonGreen.withOpacity(0.08),
          blurRadius: 30,
          spreadRadius: -6,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthFormField(
              controller: _emailController,
              label: 'Correo Electrónico',
              icon: Icons.email_outlined,
              accentColor: _neonGreen,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu correo electrónico';
                }
                if (!value.contains('@')) {
                  return 'Ingresa un correo válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthFormField(
              controller: _passwordController,
              label: 'Contraseña',
              icon: Icons.lock_outline,
              accentColor: _neonGreen,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white54,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu contraseña';
                }
                if (value.length < 6) {
                  return 'La contraseña debe tener al menos 6 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            ForgotPasswordLink(
              onTap: _loading ? null : _goToForgotPassword,
              accentColor: _neonGreen,
            ),
            const SizedBox(height: 16),
            AuthSubmitButton(
              label: 'INICIAR SESIÓN',
              isLoading: _loading,
              onTap: _handleLogin,
              accentColor: _neonGreen,
              blurred: true,
              boxShadow: [
                BoxShadow(
                  color: _neonGreen.withOpacity(0.35),
                  blurRadius: 18,
                  spreadRadius: -2,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const OrDivider(),
            const SizedBox(height: 20),
            GoogleSignInButton(
              onTap: _handleGoogleLogin,
              enabled: !_loading,
            ),
          ],
        ),
      ),
    );
  }
}