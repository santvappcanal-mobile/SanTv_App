import 'dart:io';
import 'package:flutter/material.dart';
import 'package:santv_app/models/gallery_item.dart';

const _neon = Color(0xFF39FF14);

/// Diálogo base: vista previa de la imagen + campo de descripción.
AlertDialog _descriptionDialog({
  required String title,
  required Widget preview,
  required TextEditingController controller,
  required String hint,
  required List<Widget> actions,
}) {
  return AlertDialog(
    backgroundColor: const Color(0xFF1A1A1A),
    title: Text(title, style: const TextStyle(color: Colors.white)),
    content: SizedBox(
      width: double.maxFinite,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(12), child: preview),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 150,
              maxLines: 3,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.white38),
                counterStyle: const TextStyle(color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
    ),
    actions: actions,
  );
}

/// Descripción de una imagen que se va a subir.
/// Devuelve el texto (puede ir vacío) o null si el admin cancela todo.
Future<String?> askImageDescription(
  BuildContext context, {
  required File imagen,
  required int numero,
  required int total,
}) {
  final controller = TextEditingController();
  final esUltima = numero == total;

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _descriptionDialog(
      title: total > 1 ? 'Descripción ($numero de $total)' : 'Descripción',
      preview: Image.file(imagen, height: 160, fit: BoxFit.cover),
      controller: controller,
      hint: 'Escribe una descripción (opcional)',
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, ''),
          child: const Text('Omitir'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, controller.text),
          child: Text(
            esUltima ? 'Subir' : 'Siguiente',
            style: const TextStyle(color: _neon),
          ),
        ),
      ],
    ),
  );
}

/// Edita la descripción de una imagen ya subida.
/// Devuelve el texto nuevo o null si se cancela.
Future<String?> showEditImageDescriptionDialog(
  BuildContext context,
  GalleryItem item,
) {
  final controller = TextEditingController(text: item.description);

  return showDialog<String>(
    context: context,
    builder: (dialogContext) => _descriptionDialog(
      title: 'Editar descripción',
      preview: Image.network(
        item.mediaUrl,
        height: 160,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          height: 160,
          color: const Color(0xFF0B0B0B),
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      ),
      controller: controller,
      hint: 'Escribe una descripción',
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, controller.text),
          child: const Text('Guardar', style: TextStyle(color: _neon)),
        ),
      ],
    ),
  );
}