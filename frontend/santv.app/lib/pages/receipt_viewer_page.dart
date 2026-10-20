import 'package:flutter/material.dart';

/// Visor a pantalla completa del comprobante de pago (con zoom).
class ReceiptViewerPage extends StatelessWidget {
  const ReceiptViewerPage({super.key, required this.url, required this.titulo});

  final String url;
  final String titulo;

  static const Color neonGreen = Color(0xFF39FF14);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Comprobante · $titulo',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: Image.network(
            url,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : const CircularProgressIndicator(color: neonGreen),
            errorBuilder: (_, __, ___) => const Text(
              'No se pudo cargar el comprobante',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ),
      ),
    );
  }
}
