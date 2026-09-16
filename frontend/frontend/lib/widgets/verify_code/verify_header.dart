import 'package:flutter/material.dart';

/// Encabezado de la pantalla de verificación: ícono, título y el
/// correo al que se envió el código.
class VerifyHeader extends StatelessWidget {
  const VerifyHeader({
    super.key,
    required this.email,
    this.accentColor = const Color(0xFF39FF14),
  });

  final String email;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.mark_email_read_outlined, color: accentColor, size: 64),
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
          'Enviamos un código de verificación a\n$email',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}