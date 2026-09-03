import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

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

  // Requisitos de la contraseña: label + función que evalúa si se cumple.
  static final List<_PasswordRule> _passwordRules = [
    _PasswordRule('Mínimo 6 caracteres', (v) => v.length >= 6),
    _PasswordRule('Al menos una letra', (v) => RegExp(r'[A-Za-z]').hasMatch(v)),
    _PasswordRule('Al menos un número', (v) => RegExp(r'[0-9]').hasMatch(v)),
    _PasswordRule(
      'Al menos un carácter especial (!@#\$%^&*.,_-)',
      (v) => RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(v),
    ),
  ];

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

  String? _validatePassword(String? v) {
    final value = v ?? '';
    for (final rule in _passwordRules) {
      if (!rule.isValid(value)) return rule.label;
    }
    return null;
  }

  bool get _passwordFullyValid =>
      _passwordRules.every((r) => r.isValid(_passwordController.text));

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
        _showError(result.errorMessage ?? 'No se pudo restablecer la contraseña');
      }
    } catch (e) {
      if (mounted) _showError('Error al conectar con el servidor: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: _neonGreen),
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _neonGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
    );
  }

  Widget _buildPasswordChecklist() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: !_showPasswordChecklist
          ? const SizedBox.shrink()
          : Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: _passwordRules.map((rule) {
                  final ok = rule.isValid(_passwordController.text);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Icon(
                          ok ? Icons.check_circle : Icons.cancel_outlined,
                          size: 16,
                          color: ok ? _neonGreen : Colors.white38,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            rule.label,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: ok ? Colors.white : Colors.white54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
    );
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
                          TextFormField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(
                              'Código de 6 dígitos',
                              Icons.pin_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().length != 6) {
                                return 'Ingresa el código de 6 dígitos';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Focus(
                            onFocusChange: (hasFocus) {
                              setState(() {
                                // Se mantiene visible si tiene foco, o si ya
                                // escribió algo pero aún falta cumplir reglas.
                                _showPasswordChecklist = hasFocus ||
                                    (_passwordController.text.isNotEmpty &&
                                        !_passwordFullyValid);
                              });
                            },
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration(
                                'Nueva contraseña',
                                Icons.lock_outline,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white54,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                              ),
                              validator: _validatePassword,
                            ),
                          ),
                          _buildPasswordChecklist(),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(
                              'Confirmar contraseña',
                              Icons.lock_outline,
                            ),
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: [
                                    _neonGreen.withValues(alpha: 0.85),
                                    _neonGreen.withValues(alpha: 0.55),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: _loading ? null : _handleSubmit,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    child: Center(
                                      child: _loading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.black,
                                              ),
                                            )
                                          : const Text(
                                              'RESTABLECER CONTRASEÑA',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.0,
                                                color: Colors.black,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
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

/// Un requisito de la contraseña: texto a mostrar + regla de validación.
class _PasswordRule {
  const _PasswordRule(this.label, this.isValid);
  final String label;
  final bool Function(String value) isValid;
}