import 'package:flutter/material.dart';
import 'package:santv_app/models/reference_video_item.dart';
import 'package:santv_app/widgets/admin/custom_text_field.dart';

const _neon = Color(0xFF39FF14);

/// Diálogo para corregir el título y la descripción de un video.
/// Devuelve los textos (ya sin espacios sobrantes) o null si se cancela.
Future<({String title, String description})?> showEditReferenceDialog(
  BuildContext context,
  ReferenceVideoItem item,
) async {
  final tituloCtrl = TextEditingController(text: item.title);
  final descCtrl = TextEditingController(text: item.description);

  final guardar = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text('Editar video', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(controller: tituloCtrl, label: 'Título'),
            const SizedBox(height: 12),
            CustomTextField(
              controller: descCtrl,
              label: 'Descripción',
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Guardar', style: TextStyle(color: _neon)),
        ),
      ],
    ),
  );

  if (guardar != true) return null;
  return (title: tituloCtrl.text.trim(), description: descCtrl.text.trim());
}