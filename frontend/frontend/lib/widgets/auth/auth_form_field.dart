import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthFormField extends StatelessWidget {
  const AuthFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.accentColor,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color accentColor;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;

  /// Widget opcional al final del campo (ej: el ojito para mostrar/ocultar contraseña).
  final Widget? suffixIcon;

  /// Formatters opcionales (ej: filtrar el nombre para que solo acepte letras).
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
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
      ),
      validator: validator,
    );
  }
}