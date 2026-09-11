import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/reset_password/otp_code_field.dart';
import '../widgets/reset_password/glass_password_field.dart';
import '../widgets/reset_password/password_requirements_checklist.dart';
import '../widgets/reset_password/glass_submit_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.authService,
    required this.email,
  });

  final AuthService authService;
  final String email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;

  // Controla si se muestra la checklist de la contraseña (aparece
  // al enfocar el campo, igual que en register_screen.dart).
  bool _showPasswordChecklist = false;

  static const Color _neonGreen = Color(0xFF39FF14);

  @override
  void initState() {
    super.initState();
    // Repinta la checklist en tiempo real mientras el usuario escribe.
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  bool get _passwordFullyValid =>
      defaultPasswordRules.every((r) => r.isValid(_passwordController.text));

  String? _validatePassword(String? v) {
    final value = v ?? '';
    for (final rule in defaultPasswordRules) {
      if (!rule.isValid(value)) return rule.label;
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final result = await widget.authService.resetPassword(
        email: widget.email,
        code: _codeController.text.trim(),
        newPassword: _passwordController.text,
      );
      if (!mounted) return;

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña actualizada. Inicia sesión.'),
            backgroundColor: Colors.green,
          ),
        );
        // Vuelve hasta AuthScreen (la pantalla de login/registro).
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        _showError(
          result.errorMessage ?? 'No se pudo restablecer la contraseña',
        );
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
          'Restablecer contraseña',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.10),
                          Colors.white.withValues(alpha: 0.04),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 1.2,
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Enviamos un código a ${widget.email}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 24),
                          OtpCodeField(
                            controller: _codeController,
                            accentColor: _neonGreen,
                          ),
                          const SizedBox(height: 16),
                          GlassPasswordField(
                            controller: _passwordController,
                            label: 'Nueva contraseña',
                            obscureText: _obscurePassword,
                            accentColor: _neonGreen,
                            onToggleObscure: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            validator: _validatePassword,
                            onFocusChange: (hasFocus) {
                              setState(() {
                                _showPasswordChecklist = hasFocus ||
                                    (_passwordController.text.isNotEmpty &&
                                        !_passwordFullyValid);
                              });
                            },
                          ),
                          PasswordRequirementsChecklist(
                            visible: _showPasswordChecklist,
                            password: _passwordController.text,
                            accentColor: _neonGreen,
                          ),
                          const SizedBox(height: 8),
                          GlassPasswordField(
                            controller: _confirmPasswordController,
                            label: 'Confirmar contraseña',
                            obscureText: _obscurePassword,
                            accentColor: _neonGreen,
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          GlassSubmitButton(
                            label: 'RESTABLECER CONTRASEÑA',
                            loading: _loading,
                            onPressed: _handleSubmit,
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
        ),
      ),
    );
  }
}