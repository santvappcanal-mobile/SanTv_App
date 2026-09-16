import 'package:flutter/material.dart';

/// Link "¿No recibiste el código? Reenviar", con estado de cooldown
/// en segundos para evitar spam de reenvíos.
class ResendCodeLink extends StatelessWidget {
  const ResendCodeLink({
    super.key,
    required this.resending,
    required this.cooldown,
    required this.onPressed,
  });

  final bool resending;
  final int cooldown;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (resending || cooldown > 0) ? null : onPressed,
      child: Text(
        resending
            ? 'Reenviando...'
            : cooldown > 0
                ? 'Reenviar código (${cooldown}s)'
                : '¿No recibiste el código? Reenviar',
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }
}