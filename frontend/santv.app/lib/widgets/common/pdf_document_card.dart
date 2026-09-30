import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// Tarjeta estilo Google Drive: título arriba y, debajo, la vista previa
/// de la primera página del PDF. Al tocarla se ejecuta [onTap].
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
                        child: Icon(Icons.delete, color: Colors.redAccent, size: 20),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              // Vista previa de la primera página (no interactiva)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    color: Colors.white,
                    child: IgnorePointer(
                      child: SfPdfViewer.network(
                        url,
                        key: ValueKey(url),
                        pageLayoutMode: PdfPageLayoutMode.single,
                        canShowScrollHead: false,
                        canShowScrollStatus: false,
                        canShowPaginationDialog: false,
                        enableDoubleTapZooming: false,
                        enableTextSelection: false,
                      ),
                    ),
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