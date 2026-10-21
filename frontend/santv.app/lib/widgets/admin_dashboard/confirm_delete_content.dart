import 'package:flutter/material.dart';
import 'dashboard_style.dart';

Future<bool> confirmarEliminarContenido(
  BuildContext context,
  String titulo,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: kCardBg,
      title: const Text(
        'Eliminar contenido',
        style: TextStyle(color: Colors.white),
      ),
      content: Text(
        '¿Seguro que quieres eliminar "$titulo"? '
        'Esta acción no se puede deshacer.',
        style: const TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
  return ok == true;
}