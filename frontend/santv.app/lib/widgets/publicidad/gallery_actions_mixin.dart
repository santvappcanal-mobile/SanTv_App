import 'dart:io';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter/material.dart';
import 'package:santv_app/models/gallery_item.dart';
import 'package:santv_app/services/ad_service.dart';
import 'package:santv_app/widgets/ads/confirm_delete_dialog.dart';
import 'image_description_dialogs.dart';
import 'publicidad_controller.dart';
import 'publicidad_dialogs.dart';

/// Acciones de la pestaña Portafolio: subir, editar descripción y
/// eliminar imágenes.
mixin GalleryActionsMixin<T extends StatefulWidget> on State<T> {
  AdService get adService;
  PublicidadController get publicidad;

  /// Flujo: elegir imágenes -> descripción de cada una -> subir con indicador.
  Future<void> seleccionarYSubirImagenes() async {
    // En file_picker 13.x, pickFiles ya permite varias y devuelve
    // List<PlatformFile> (vacía si cancelas).
    final picked = await fp.FilePicker.pickFiles(type: fp.FileType.image);

    final archivos = <File>[
      for (final f in picked)
        if (f.path != null) File(f.path!),
    ];
    if (archivos.isEmpty) return;
    if (!mounted) return;

    // Pedimos la descripción de cada imagen (en orden)
    final descripciones = <String>[];
    for (var i = 0; i < archivos.length; i++) {
      final desc = await askImageDescription(
        context,
        imagen: archivos[i],
        numero: i + 1,
        total: archivos.length,
      );
      if (desc == null) return; // canceló: no se sube nada
      descripciones.add(desc);
      if (!mounted) return;
    }

    showUploadingDialog(context, 'Subiendo imágenes...');
    final error = await adService.uploadGalleryImages(
      archivos,
      descripciones: descripciones,
    );

    if (!mounted) return;
    closeUploadingDialog(context);

    if (error == null) {
      await publicidad.cargarGaleria();
      if (!mounted) return;
      showPublicidadSnack(context, 'Imágenes subidas correctamente');
    } else {
      showPublicidadSnack(context, error);
    }
  }

  /// Edita la descripción de una imagen ya subida.
  Future<void> editarDescripcion(GalleryItem item) async {
    final nuevo = await showEditImageDescriptionDialog(context, item);

    // null = canceló; si no cambió nada, no hacemos la petición
    if (nuevo == null || nuevo.trim() == item.description.trim()) return;
    if (!mounted) return;

    final error = await adService.actualizarDescripcionImagen(item.id, nuevo);
    if (!mounted) return;

    if (error == null) {
      await publicidad.cargarGaleria();
      if (!mounted) return;
      showPublicidadSnack(context, 'Descripción actualizada');
    } else {
      showPublicidadSnack(context, error);
    }
  }

  Future<void> eliminarImagen(GalleryItem item) async {
    final ok = await ConfirmDeleteDialog.show(
      context,
      title: 'Eliminar imagen',
      message: '¿Seguro que deseas eliminarla?',
    );
    if (!ok || !mounted) return;

    final exito = await adService.eliminarAd(item.id);
    if (!mounted) return;

    if (exito) {
      await publicidad.cargarGaleria();
    } else {
      showPublicidadSnack(context, 'Error al eliminar la imagen');
    }
  }
}