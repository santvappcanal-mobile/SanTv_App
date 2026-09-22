import 'package:flutter/material.dart';
import 'glass_input_decoration.dart';

/// Campo de contraseña en vidrio. Si [onToggleObscure] no es nulo,
/// muestra el ícono de ojo para mostrar/ocultar el texto.
class GlassPasswordField extends StatelessWidget {
  const GlassPasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.obscureText,
    required this.accentColor,
    this.onToggleObscure,
    this.validator,
    this.onFocusChange,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final Color accentColor;
  final VoidCallback? onToggleObscure;
  final String? Function(String?)? validator;
  final void Function(bool hasFocus)? onFocusChange;

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: glassInputDecoration(
        label: label,
        icon: Icons.lock_outline,
        accentColor: accentColor,
        suffixIcon: onToggleObscure == null
            ? null
            : IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white54,
                ),
                onPressed: onToggleObscure,
              ),
      ),
      validator: validator,
    );

    if (onFocusChange == null) return field;
    return Focus(onFocusChange: onFocusChange, child: field);
  }
}