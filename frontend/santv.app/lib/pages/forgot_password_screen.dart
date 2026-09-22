import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/auth/auth_frosted_card.dart';
import '../widgets/auth/auth_form_field.dart';
import '../widgets/auth/auth_submit_button.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _loading = false;

  static const Color _neonGreen = Color(0xFF39FF14);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final result = await widget.authService.forgotPassword(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;

      if (result.success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(
              authService: widget.authService,
              email: _emailController.text.trim(),
            ),
          ),
        );
      } else {
        _showError(result.errorMessage ?? 'No se pudo enviar el código');
      }
    } catch (e) {
      if (mounted) _showError('Error al conectar con el servidor: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Recuperar contraseña',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AuthFrostedCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Ingresa tu correo y te enviaremos un código para restablecer tu contraseña.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 24),
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
                      const SizedBox(height: 24),
                      AuthSubmitButton(
                        label: 'ENVIAR CÓDIGO',
                        isLoading: _loading,
                        onTap: _handleSubmit,
                        accentColor: _neonGreen,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}