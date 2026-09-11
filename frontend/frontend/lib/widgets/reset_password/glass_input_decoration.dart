import 'package:flutter/material.dart';

/// Decoración compartida para los campos de formulario "en vidrio"
/// de las pantallas de autenticación (login, registro, reset password).
InputDecoration glassInputDecoration({
  required String label,
  required IconData icon,
  required Color accentColor,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white70),
    prefixIcon: Icon(icon, color: accentColor),
    suffixIcon: suffixIcon,
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
      borderSide: BorderSide(color: accentColor, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
    ),
  );
}