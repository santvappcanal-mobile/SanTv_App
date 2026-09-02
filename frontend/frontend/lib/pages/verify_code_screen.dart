import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

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
  static const Color _fieldFill = Color(0xFF1A1A1A);

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

  InputDecoration _codeDecoration() {
    return InputDecoration(
      labelText: 'Código de verificación',
      labelStyle: const TextStyle(color: Colors.white70),
      counterText: '',
      prefixIcon: const Icon(Icons.pin_outlined, color: _neonGreen),
      filled: true,
      fillColor: _fieldFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _neonGreen, width: 2),
      ),
    );
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
                const Icon(
                  Icons.mark_email_read_outlined,
                  color: _neonGreen,
                  size: 64,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Confirma tu correo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enviamos un código de verificación a\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    letterSpacing: 8,
                  ),
                  decoration: _codeDecoration(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el código';
                    }
                    if (value.trim().length < 4) {
                      return 'Código incompleto';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _handleVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _neonGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
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
                          'CONFIRMAR CÓDIGO',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: (_resending || _cooldown > 0)
                      ? null
                      : _handleResend,
                  child: Text(
                    _resending
                        ? 'Reenviando...'
                        : _cooldown > 0
                        ? 'Reenviar código (${_cooldown}s)'
                        : '¿No recibiste el código? Reenviar',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
