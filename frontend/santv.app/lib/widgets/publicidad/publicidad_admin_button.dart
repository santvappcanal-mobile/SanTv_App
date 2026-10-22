import 'package:flutter/material.dart';

const _neon = Color(0xFF39FF14);

/// Botón verde de acción del admin (Agregar video, Subir PDF, Subir imágenes).
class PublicidadAdminButton extends StatelessWidget {
  const PublicidadAdminButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: _neon),
        icon: Icon(icon, color: Colors.black),
        label: Text(label, style: const TextStyle(color: Colors.black)),
        onPressed: onPressed,
      ),
    );
  }
}