import 'package:flutter/material.dart';
import 'package:santv_app/models/ad_document_item.dart';
import 'package:santv_app/widgets/common/pdf_document_card.dart';
import 'publicidad_admin_button.dart';
import 'publicidad_controller.dart';
import 'publicidad_tab.dart';

/// Pestaña Documentos: PDFs/brochures vía Cloudinary.
/// Solo el admin puede subir/eliminar; usuarios normales solo ven/descargan.
class DocumentsTab extends StatelessWidget {
  const DocumentsTab({
    super.key,
    required this.state,
    required this.esAdmin,
    required this.onReload,
    required this.onUpload,
    required this.onOpen,
    required this.onDelete,
  });

  final LoadableList<AdDocumentItem> state;
  final bool esAdmin;
  final Future<void> Function() onReload;
  final VoidCallback onUpload;
  final ValueChanged<AdDocumentItem> onOpen;
  final ValueChanged<AdDocumentItem> onDelete;

  @override
  Widget build(BuildContext context) {
    return PublicidadTab(
      cargando: state.cargando,
      error: state.error,
      onReload: onReload,
      isEmpty: state.items.isEmpty,
      emptyText: 'No hay documentos aún',
      adminButton: esAdmin
          ? PublicidadAdminButton(
              icon: Icons.upload_file,
              label: 'Subir PDF',
              onPressed: onUpload,
            )
          : null,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        itemCount: state.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final doc = state.items[index];
          return SizedBox(
            height: 220, // rectángulo de ancho completo
            child: PdfDocumentCard(
              titulo: doc.title,
              url: doc.mediaUrl,
              onDelete: esAdmin ? () => onDelete(doc) : null,
              onTap: () => onOpen(doc),
            ),
          );
        },
      ),
    );
  }
}