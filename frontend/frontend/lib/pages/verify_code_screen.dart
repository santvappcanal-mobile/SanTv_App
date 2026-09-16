import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/verify_code/verify_header.dart';
import '../widgets/verify_code/code_input_field.dart';
import '../widgets/verify_code/verify_button.dart';
import '../widgets/verify_code/resend_code_link.dart';

/// Pantalla de verificación de correo. Se muestra automáticamente
/// después de un registro exitoso (cuando `pendingVerification` es
/// true), recibiendo el email al que se envió el código.
class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({
    super.key,
    required this.authService,
    required this.email,
    this.onVerified,
    this.onCancel,
  });

  final AuthService authService;

  /// Correo al que se envió el código (viene del registro).
  final String email;

  /// Se llama cuando el código fue validado correctamente.
  final void Function()? onVerified;

  /// Se llama si el usuario decide volver atrás (a login/registro).
  final void Function()? onCancel;

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  bool _loading = false;
  bool _resending = false;

  // Reenvío con cooldown de 60s para evitar spam de códigos.
  int _cooldown = 0;
  Timer? _timer;

  static const Color _neonGreen = Color(0xFF39FF14);

  @override
  void dispose() {
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: _neonGreen),
    );
  }

  void _startCooldown() {
    setState(() => _cooldown = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldown <= 1) {
        timer.cancel();
        setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown--);
      }
    });
  }

  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final result = await widget.authService.verifyCode(
        email: widget.email,
        code: _codeController.text.trim(),
      );
      if (!mounted) return;

      if (result.success) {
        widget.onVerified?.call();
      } else {
        _showError(result.errorMessage ?? 'Código incorrecto o expirado');
      }
    } catch (e) {
      if (mounted) _showError('Error al verificar el código: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleResend() async {
    if (_cooldown > 0) return;

    setState(() => _resending = true);
    try {
      final result = await widget.authService.resendCode(email: widget.email);
      if (!mounted) return;

      if (result.success) {
        _showInfo('Te enviamos un nuevo código a ${widget.email}');
        _startCooldown();
      } else {
        _showError(result.errorMessage ?? 'No se pudo reenviar el código');
      }
    } catch (e) {
      if (mounted) _showError('Error al reenviar el código: $e');
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onCancel,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                VerifyHeader(email: widget.email),
                const SizedBox(height: 32),
                CodeInputField(controller: _codeController),
                const SizedBox(height: 24),
                VerifyButton(loading: _loading, onPressed: _handleVerify),
                const SizedBox(height: 20),
                ResendCodeLink(
                  resending: _resending,
                  cooldown: _cooldown,
                  onPressed: _handleResend,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}