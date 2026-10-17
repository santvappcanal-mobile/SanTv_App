import 'dart:io';
import 'package:flutter/material.dart';
import '../admin/custom_text_field.dart';

/// Pide título y enlace del anuncio. Devuelve {'titulo', 'enlace'} o null.
class NewAdDialog extends StatefulWidget {
  const NewAdDialog({super.key, required this.imagen});

  final File imagen;

  @override
  State<NewAdDialog> createState() => _NewAdDialogState();
}

class _NewAdDialogState extends State<NewAdDialog> {
  final _titulo = TextEditingController();
  final _enlace = TextEditingController();

  @override
  void dispose() {
    _titulo.dispose();
    _enlace.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text('Nuevo anuncio', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(widget.imagen, height: 140, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
            CustomTextField(controller: _titulo, label: 'Título'),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _enlace,
              label: 'Enlace al tocar (opcional)',
              hint: 'https://...',
              keyboardType: TextInputType.url,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF39FF14),
          ),
          onPressed: () => Navigator.pop(context, {
            'titulo': _titulo.text.trim().isEmpty
                ? 'Anuncio'
                : _titulo.text.trim(),
            'enlace': _enlace.text.trim(),
          }),
          child: const Text('Publicar', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}