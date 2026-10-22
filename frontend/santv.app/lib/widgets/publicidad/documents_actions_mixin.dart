import 'dart:io';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter/material.dart';
import 'package:santv_app/models/ad_document_item.dart';
import 'package:santv_app/pages/pdf_viewer_page.dart';
import 'package:santv_app/services/ad_service.dart';
import 'package:santv_app/widgets/ads/confirm_delete_dialog.dart';
import 'publicidad_controller.dart';
import 'publicidad_dialogs.dart';

/// Acciones de la pestaña Documentos: ver, subir y eliminar PDFs.
mixin DocumentsActionsMixin<T extends StatefulWidget> on State<T> {
  AdService get adService;
  PublicidadController get publicidad;

  void abrirDocumento(AdDocumentItem doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerPage(url: doc.mediaUrl, titulo: doc.title),
      ),
    );
  }

  /// Flujo: elegir PDF -> vista previa -> confirmar -> nombre -> subir.
  Future<void> seleccionarYSubirPdf() async {
    final picked = await fp.FilePicker.pickFile(
      type: fp.FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (picked == null || picked.path == null) return;
    if (!mounted) return;

    final file = File(picked.path!);

    // Vista previa antes de subir
    final confirmar = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PdfViewerPage(file: file, titulo: picked.name, confirmar: true),
      ),
    );
    if (confirmar != true || !mounted) return;

    final titulo = await askTitle(
      context,
      title: 'Nombre del documento',
      hint: 'Ej. Reseña SanTv 2026',
    );
    if (titulo == null || titulo.trim().isEmpty) return;

    final exito = await adService.uploadDocument(file, titulo.trim());
    if (!mounted) return;

    if (exito) {
      await publicidad.cargarDocumentos();
      if (!mounted) return;
      showPublicidadSnack(context, 'Documento subido correctamente');
    } else {
      showPublicidadSnack(context, 'Error al subir el documento');
    }
  }

  Future<void> eliminarDocumento(AdDocumentItem doc) async {
    final ok = await ConfirmDeleteDialog.show(
      context,
      title: 'Eliminar documento',
      message: '¿Seguro que deseas eliminarlo?',
    );
    if (!ok || !mounted) return;

    final exito = await adService.deleteDocument(doc.id);
    if (!mounted) return;

    if (exito) {
      await publicidad.cargarDocumentos();
    } else {
      showPublicidadSnack(context, 'Error al eliminar el documento');
    }
  }
}