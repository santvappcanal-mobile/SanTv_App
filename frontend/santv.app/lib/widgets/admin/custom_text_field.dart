import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.requerido = false,
    this.tipoNumerico = false,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final bool requerido;
  final bool tipoNumerico;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: tipoNumerico ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF141414),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: requerido
          ? (value) =>
              (value == null || value.trim().isEmpty) ? 'Campo obligatorio' : null
          : null,
    );
  }
}