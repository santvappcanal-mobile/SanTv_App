import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.requerido = false,
    this.tipoNumerico = false,
    this.maxLines = 1,
    this.suffixIcon,
    this.onSubmitted,
    this.hint,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final bool requerido;
  final bool tipoNumerico;
  final int maxLines;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;
  final String? hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType:
          keyboardType ??
          (tipoNumerico ? TextInputType.number : TextInputType.text),
      style: const TextStyle(color: Colors.white),
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.white54),
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: const Color(0xFF141414),
        suffixIcon: suffixIcon,
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