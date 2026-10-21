import 'package:flutter/material.dart';

/// Botón flotante que abre el chat del asistente.
class AssistantFab extends StatelessWidget {
  const AssistantFab({
    super.key,
    required this.onPressed,
    required this.neonColor,
  });

  final VoidCallback onPressed;
  final Color neonColor;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: neonColor,
      child: const Icon(Icons.smart_toy_outlined, color: Colors.black),
    );
  }
}