import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';

/// Tarjeta estilo Google Drive: título arriba y, debajo, la vista previa
/// de la primera página del PDF (como imagen). Al tocarla se ejecuta [onTap].
/// Si [onDelete] no es null (admin), muestra el ícono de eliminar.
class PdfDocumentCard extends StatelessWidget {
  const PdfDocumentCard({
    super.key,
    required this.titulo,
    required this.url,
    required this.onTap,
    this.onDelete,
  });

  final String titulo;
  final String url;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  static const Color neonGreen = Color(0xFF39FF14);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado: ícono + título + eliminar (admin)
              Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: neonGreen, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (onDelete != null)
                    InkResponse(
                      onTap: onDelete,
                      radius: 18,
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(Icons.delete,
                            color: Colors.redAccent, size: 20),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              // Vista previa de la primera página (imagen, no interactiva)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ColoredBox(
                    color: Colors.white,
                    child: SizedBox.expand(child: _PdfThumb(url: url)),
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

/// Miniatura de la primera página de un PDF remoto, renderizada como imagen.
class _PdfThumb extends StatefulWidget {
  const _PdfThumb({required this.url});
  final String url;

  @override
  State<_PdfThumb> createState() => _PdfThumbState();
}

class _PdfThumbState extends State<_PdfThumb> {
  // Caché en memoria: evita volver a descargar al hacer scroll o al volver
  // de otra pantalla.
  static final Map<String, Uint8List> _cache = {};

  late final Future<Uint8List?> _future = _load();

  Future<Uint8List?> _load() async {
    final cached = _cache[widget.url];
    if (cached != null) return cached;

    try {
      final res = await http.get(Uri.parse(widget.url));
      if (res.statusCode != 200) return null;

      final doc = await PdfDocument.openData(res.bodyBytes);
      final page = await doc.getPage(1);
      final img = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: PdfPageImageFormat.jpeg,
      );
      await page.close();
      await doc.close();

      final bytes = img?.bytes;
      if (bytes != null) _cache[widget.url] = bytes;
      return bytes;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF39FF14),
            ),
          );
        }
        if (snap.data == null) {
          return const Center(
            child: Icon(Icons.picture_as_pdf, color: Colors.grey, size: 40),
          );
        }
        return Image.memory(
          snap.data!,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          gaplessPlayback: true,
        );
      },
    );
  }
}