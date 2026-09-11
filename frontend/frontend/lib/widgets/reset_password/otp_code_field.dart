import 'package:flutter/material.dart';
import 'glass_input_decoration.dart';

/// Campo para el código de verificación de 6 dígitos, en vidrio.
class OtpCodeField extends StatelessWidget {
  const OtpCodeField({
    super.key,
    required this.controller,
    required this.accentColor,
  });

  final TextEditingController controller;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 6,
      style: const TextStyle(color: Colors.white),
      decoration: glassInputDecoration(
        label: 'Código de 6 dígitos',
        icon: Icons.pin_outlined,
        accentColor: accentColor,
      ),
      validator: (value) {
        if (value == null || value.trim().length != 6) {
          return 'Ingresa el código de 6 dígitos';
        }
        return null;
      },
    );
  }
}