import 'package:flutter/material.dart';

const Color _neonGreen = Color(0xFF39FF14);
const Color _card = Color(0xFF1A1A1A);

/// Aviso tras registrar una solicitud pagada en efectivo.
Future<void> showCashInfoDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: _card,
      title: const Text(
        'Solicitud registrada',
        style: TextStyle(color: Colors.white),
      ),
      content: const Text(
        'Acércate a las oficinas del canal para realizar el pago en efectivo. '
        'Un administrador confirmará tu pago y te avisaremos por notificación.',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendido', style: TextStyle(color: _neonGreen)),
        ),
      ],
    ),
  );
}

/// Confirmación genérica. Devuelve true si el usuario acepta.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  Color confirmColor = _neonGreen,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: _card,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      content: Text(message, style: const TextStyle(color: Colors.white70)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel, style: TextStyle(color: confirmColor)),
        ),
      ],
    ),
  );
  return ok == true;
}

/// Pide el motivo de la invalidación. Devuelve el texto (puede ir vacío)
/// o null si el admin cancela.
Future<String?> showInvalidateDialog(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: _card,
      title: const Text(
        'Invalidar pago',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'La solicitud se cancelará y se le avisará al cliente.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLength: 200,
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Motivo (ej. comprobante no válido)',
              hintStyle: TextStyle(color: Colors.white38),
              counterStyle: TextStyle(color: Colors.white38),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: const Text(
            'Invalidar',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    ),
  );
}
