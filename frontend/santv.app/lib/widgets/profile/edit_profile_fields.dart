import 'package:flutter/material.dart';
import 'profile_form_field.dart';

const _neon = Color(0xFF39FF14);

String? _validarNombre(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'El nombre es obligatorio';
  final nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
  if (!nameRegex.hasMatch(v)) return 'El nombre solo puede contener letras';
  return null;
}

String? _validarCorreo(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'El correo es obligatorio';
  if (!v.contains('@')) return 'Correo inválido';
  return null;
}

/// Campos de nombre y correo, con sus validaciones.
class EditProfileFields extends StatelessWidget {
  const EditProfileFields({
    super.key,
    required this.nameCtrl,
    required this.emailCtrl,
  });

  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileFormField(
          controller: nameCtrl,
          label: 'Nombre',
          accentColor: _neon,
          validator: _validarNombre,
        ),
        const SizedBox(height: 16),
        ProfileFormField(
          controller: emailCtrl,
          label: 'Correo',
          accentColor: _neon,
          keyboardType: TextInputType.emailAddress,
          validator: _validarCorreo,
        ),
      ],
    );
  }
}