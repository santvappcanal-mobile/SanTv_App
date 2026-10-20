import 'dart:io';
import 'package:flutter/material.dart';

/// Recuadro para elegir y previsualizar la captura del pago.
class ReceiptPicker extends StatelessWidget {
  const ReceiptPicker({super.key, required this.file, required this.onPick});

  final File? file;
  final VoidCallback onPick;

  static const Color neonGreen = Color(0xFF39FF14);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: neonGreen.withValues(alpha: 0.5)),
        ),
        child: file == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      color: neonGreen, size: 40),
                  SizedBox(height: 8),
                  Text(
                    'Sube la captura de tu pago',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(file!, fit: BoxFit.cover),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Cambiar',
                          style: TextStyle(color: neonGreen, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
