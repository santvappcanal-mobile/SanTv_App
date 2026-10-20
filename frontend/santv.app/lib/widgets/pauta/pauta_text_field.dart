import 'package:flutter/material.dart';

/// Campo de texto con el estilo oscuro/neón de la app.
class PautaTextField extends StatelessWidget {
  const PautaTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;

  static const Color neonGreen = Color(0xFF39FF14);

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color),
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          counterStyle: const TextStyle(color: Colors.white38),
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          enabledBorder: border(Colors.transparent),
          focusedBorder: border(neonGreen),
          errorBorder: border(Colors.redAccent),
          focusedErrorBorder: border(Colors.redAccent),
        ),
      ),
    );
  }
}
