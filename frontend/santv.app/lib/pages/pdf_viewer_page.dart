import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// Visor de PDF.
/// - Con [url]: muestra un PDF ya subido (red).
/// - Con [file]: muestra la vista previa de un PDF local antes de subirlo.
/// - Con [confirmar] = true: muestra los botones Cancelar / Subir y
///   devuelve true/false con Navigator.pop.
class PdfViewerPage extends StatelessWidget {
  final String? url;
  final File? file;
  final String titulo;
  final bool confirmar;

  const PdfViewerPage({
    super.key,
    this.url,
    this.file,
    required this.titulo,
    this.confirmar = false,
  }) : assert(url != null || file != null);

  static const Color neonGreen = Color(0xFF39FF14);

  void _onError(BuildContext context, PdfDocumentLoadFailedDetails details) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No se pudo abrir el PDF: ${details.description}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          titulo,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: file != null
          ? SfPdfViewer.file(
              file!,
              pageLayoutMode: PdfPageLayoutMode.continuous,
              enableDoubleTapZooming: true,
              onDocumentLoadFailed: (d) => _onError(context, d),
            )
          : SfPdfViewer.network(
              url!,
              pageLayoutMode: PdfPageLayoutMode.continuous,
              enableDoubleTapZooming: true,
              onDocumentLoadFailed: (d) => _onError(context, d),
            ),
      bottomNavigationBar: confirmar
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: neonGreen,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Subir'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}