import 'package:flutter/material.dart';

class UploadAdFab extends StatelessWidget {
  const UploadAdFab({
    super.key,
    required this.onPressed,
    this.accentColor = const Color(0xFF39FF14),
  });

  final VoidCallback onPressed;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: accentColor,
      icon: const Icon(Icons.add_photo_alternate, color: Colors.black),
      label: const Text('Subir imagen', style: TextStyle(color: Colors.black)),
      onPressed: onPressed,
    );
  }
}