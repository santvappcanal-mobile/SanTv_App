import 'package:flutter/material.dart';

/// Campo del código de verificación, centrado y con dígitos
/// espaciados (estilo "código grande").
class CodeInputField extends StatelessWidget {
  const CodeInputField({
    super.key,
    required this.controller,
    this.accentColor = const Color(0xFF39FF14),
    this.fillColor = const Color(0xFF1A1A1A),
  });

  final TextEditingController controller;
  final Color accentColor;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 6,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        letterSpacing: 8,
      ),
      decoration: InputDecoration(
        labelText: 'Código de verificación',
        labelStyle: const TextStyle(color: Colors.white70),
        counterText: '',
        prefixIcon: Icon(Icons.pin_outlined, color: accentColor),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ingresa el código';
        }
        if (value.trim().length < 4) {
          return 'Código incompleto';
        }
        return null;
      },
    );
  }
}