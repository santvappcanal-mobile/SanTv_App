import 'dart:io';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter/material.dart';
import 'package:santv_app/models/reference_video_item.dart';
import 'package:santv_app/pages/reference_video_player_page.dart';
import 'package:santv_app/services/ad_service.dart';
import 'package:santv_app/widgets/ads/confirm_delete_dialog.dart';
import 'edit_reference_dialog.dart';
import 'publicidad_controller.dart';
import 'publicidad_dialogs.dart';

/// Acciones de la pestaña Referencias: ver, subir, editar y eliminar videos.
mixin ReferencesActionsMixin<T extends StatefulWidget> on State<T> {
  /// Límite del plan gratuito de Cloudinary para videos (100 MB).
  static const int _maxVideoBytes = 100 * 1024 * 1024;

  AdService get adService;
  PublicidadController get publicidad;

  void abrirReferencia(ReferenceVideoItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReferenceVideoPlayerPage(
          url: item.mediaUrl,
          titulo: item.title,
        ),
      ),
    );
  }

  /// Flujo: elegir video -> validar tamaño -> nombre -> subir con indicador.
  Future<void> seleccionarYSubirVideo() async {
    final picked = await fp.FilePicker.pickFile(type: fp.FileType.video);
    if (picked == null || picked.path == null) return;
    if (!mounted) return;

    final file = File(picked.path!);

    final bytes = await file.length();
    if (bytes > _maxVideoBytes) {
      if (!mounted) return;
      final mb = (bytes / (1024 * 1024)).toStringAsFixed(1);
      showPublicidadSnack(
        context,
        'El video pesa $mb MB y el máximo permitido es 100 MB. '
        'Comprímelo e inténtalo de nuevo.',
      );
      return;
    }

    final titulo = await askTitle(
      context,
      title: 'Nombre del video',
      hint: 'Ej. Spot restaurante La Plaza',
    );
    if (titulo == null || titulo.trim().isEmpty) return;
    if (!mounted) return;

    showUploadingDialog(context, 'Subiendo video, no cierres la app...');
    final error = await adService.uploadReferenceVideo(file, titulo.trim());

    if (!mounted) return;
    closeUploadingDialog(context);

    if (error == null) {
      await publicidad.cargarReferencias();
      if (!mounted) return;
      showPublicidadSnack(context, 'Video subido correctamente');
    } else {
      showPublicidadSnack(context, error);
    }
  }

  Future<void> editarReferencia(ReferenceVideoItem item) async {
    final r = await showEditReferenceDialog(context, item);
    if (r == null || !mounted) return;

    if (r.title.isEmpty) {
      showPublicidadSnack(context, 'El título no puede estar vacío');
      return;
    }

    final error = await adService.updateReference(
      item.id,
      title: r.title,
      description: r.description,
    );
    if (!mounted) return;

    if (error == null) {
      await publicidad.cargarReferencias();
      if (!mounted) return;
      showPublicidadSnack(context, 'Video actualizado');
    } else {
      showPublicidadSnack(context, error);
    }
  }

  Future<void> eliminarReferencia(ReferenceVideoItem item) async {
    final ok = await ConfirmDeleteDialog.show(
      context,
      title: 'Eliminar video',
      message: '¿Seguro que deseas eliminarlo?',
    );
    if (!ok || !mounted) return;

    final exito = await adService.deleteReference(item.id);
    if (!mounted) return;

    if (exito) {
      await publicidad.cargarReferencias();
    } else {
      showPublicidadSnack(context, 'Error al eliminar el video');
    }
  }
}