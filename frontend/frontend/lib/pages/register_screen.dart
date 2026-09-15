import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../widgets/auth/auth_frosted_card.dart';
import '../widgets/auth/auth_form_field.dart';
import '../widgets/auth/auth_submit_button.dart';
import '../widgets/auth/or_divider.dart';
import '../widgets/auth/google_signin_button.dart';
import '../widgets/register/password_requirements_checklist.dart';

/// Formulario de registro con estilo glassmorfismo. Se usa embebido
/// dentro de [AuthScreen] (pages/auth_screen.dart), dentro de la
/// pestaña "Registrarse". Toda la lógica de registro vive aquí,
/// separada del login.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.authService,
    this.onRegistered,
    this.onLoggedIn,
  });

  final AuthService authService;

  /// Se llama con el correo cuando el registro exitoso queda
  /// pendiente de verificación por código.
  final void Function(String email)? onRegistered;

  /// Se llama cuando el registro con Google entra directo (sin
  /// pasar por código, porque el correo ya viene verificado).
  final void Function()? onLoggedIn;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  // Controla si se muestra la checklist de la contraseña (aparece
  // al enfocar el campo, ya que antes no aporta nada).
  bool _showPasswordChecklist = false;

  static const Color _neonGreen = Color(0xFF39FF14);

  static final RegExp _nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');

  // Requisitos de la contraseña: label + función que evalúa si se cumple.
  static final List<PasswordRule> _passwordRules = [
    PasswordRule('Mínimo 6 caracteres', (v) => v.length >= 6),
    PasswordRule('Al menos una letra', (v) => RegExp(r'[A-Za-z]').hasMatch(v)),
    PasswordRule('Al menos un número', (v) => RegExp(r'[0-9]').hasMatch(v)),
    PasswordRule(
      'Al menos un carácter especial (!@#\$%^&*.,_-)',
      (v) => RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(v),
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Repinta la checklist en tiempo real mientras el usuario escribe.
    _passwordCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa tu nombre';
    if (!_nameRegex.hasMatch(v.trim())) {
      return 'El nombre solo puede contener letras';
    }
    return null;
  }

  String? _validatePassword(String? v) {
    final value = v ?? '';
    for (final rule in _passwordRules) {
      if (!rule.isValid(value)) return rule.label;
    }
    return null;
  }

  bool get _passwordFullyValid =>
      _passwordRules.every((r) => r.isValid(_passwordCtrl.text));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final result = await widget.authService.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success && result.pendingVerification) {
      widget.onRegistered?.call(_emailCtrl.text.trim());
    } else if (result.success) {
      widget.onLoggedIn?.call();
    } else {
      _showError(result.errorMessage ?? 'No se pudo completar el registro.');
    }
  }

  Future<void> _registerWithGoogle() async {
    setState(() => _loading = true);
    final result = await widget.authService.loginWithGoogle();
    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      widget.onLoggedIn?.call();
    } else {
      _showError(result.errorMessage ?? 'No se pudo continuar con Google.');
    }
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
              controller: _nameCtrl,
              label: 'Nombre completo',
              icon: Icons.person_outline,
              accentColor: _neonGreen,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'),
                ),
              ],
              validator: _validateName,
            ),
            const SizedBox(height: 16),
            AuthFormField(
              controller: _emailCtrl,
              label: 'Correo electrónico',
              icon: Icons.email_outlined,
              accentColor: _neonGreen,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
                if (!v.contains('@')) return 'Correo no válido';
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
                      (_passwordCtrl.text.isNotEmpty && !_passwordFullyValid);
                });
              },
              child: AuthFormField(
                controller: _passwordCtrl,
                label: 'Contraseña',
                icon: Icons.lock_outline,
                accentColor: _neonGreen,
                obscureText: _obscurePass,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePass ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white54,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePass = !_obscurePass),
                ),
                validator: _validatePassword,
              ),
            ),
            PasswordRequirementsChecklist(
              visible: _showPasswordChecklist,
              rules: _passwordRules,
              currentValue: _passwordCtrl.text,
              accentColor: _neonGreen,
            ),
            const SizedBox(height: 8),
            AuthFormField(
              controller: _confirmCtrl,
              label: 'Confirmar contraseña',
              icon: Icons.lock_outline,
              accentColor: _neonGreen,
              obscureText: _obscureConfirm,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white54,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              validator: (v) {
                if (v != _passwordCtrl.text) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            AuthSubmitButton(
              label: 'CREAR CUENTA',
              isLoading: _loading,
              onTap: _submit,
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
              onTap: _registerWithGoogle,
              enabled: !_loading,
              label: 'Registrarme con Google',
            ),
          ],
        ),
      ),
    );
  }
}