import 'package:flutter/material.dart';

/// Aviso que aparece cuando el canal pasa a EN VIVO.
class LiveStartedSnackBar {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onView,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1A1A1A),
        duration: const Duration(seconds: 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(message, style: const TextStyle(color: Colors.white70)),
          ],
        ),
        action: SnackBarAction(
          label: 'VER',
          textColor: const Color(0xFF39FF14),
          onPressed: onView,
        ),
      ),
    );
  }
}