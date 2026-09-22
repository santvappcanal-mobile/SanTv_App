import 'package:flutter/material.dart';

class AuthFooter extends StatelessWidget {
  const AuthFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      '© 2026 SAN TV. Todos los derechos reservados.',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white38, fontSize: 12),
    );
  }
}