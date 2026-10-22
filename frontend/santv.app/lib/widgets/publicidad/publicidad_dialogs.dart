import 'package:flutter/material.dart';

const _neon = Color(0xFF39FF14);
const _dialogBg = Color(0xFF1A1A1A);

void showPublicidadSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

/// Diálogo de "subiendo..." que no se puede cerrar tocando afuera.
/// Se cierra con [closeUploadingDialog].
void showUploadingDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(
      canPop: false,
      child: AlertDialog(
        backgroundColor: _dialogBg,
        content: Row(
          children: [
            const CircularProgressIndicator(color: _neon),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void closeUploadingDialog(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}

/// Diálogo genérico para pedir el nombre de un documento o video.
/// Devuelve el texto o null si se cancela.
Future<String?> askTitle(
  BuildContext context, {
  required String title,
  required String hint,
}) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: _dialogBg,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      content: TextField(
        controller: controller,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, controller.text),
          child: const Text('Subir', style: TextStyle(color: _neon)),
        ),
      ],
    ),
  );
}