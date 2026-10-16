import 'package:flutter/material.dart';
import '../../models/admin_stats.dart';
import 'custom_text_field.dart';

/// Diálogo de edición (título obligatorio, descripción opcional).
/// Lo usa la pantalla Contenido y también el Top 5 del dashboard.
/// Devuelve {'title', 'description'} o null si se cancela.
class EditContentDialog extends StatefulWidget {
  const EditContentDialog({super.key, required this.item});

  final TopContentItem item;

  @override
  State<EditContentDialog> createState() => _EditContentDialogState();
}

class _EditContentDialogState extends State<EditContentDialog> {
  late final _titleCtrl = TextEditingController(text: widget.item.title);
  late final _descCtrl = TextEditingController(text: widget.item.description);
  String? _validationError;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _validationError = 'El título no puede estar vacío');
      return;
    }
    Navigator.pop(context, {
      'title': title,
      'description': _descCtrl.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text(
        'Editar contenido',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(controller: _titleCtrl, label: 'Título'),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _descCtrl,
              label: 'Descripción (opcional)',
              maxLines: 4,
            ),
            if (_validationError != null) ...[
              const SizedBox(height: 12),
              Text(
                _validationError!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: _guardar,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF39FF14),
          ),
          child: const Text('Guardar', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}