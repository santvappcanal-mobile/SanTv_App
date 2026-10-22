import 'package:flutter/material.dart';
import 'package:santv_app/models/gallery_item.dart';
import 'package:santv_app/widgets/common/gallery_grid.dart';
import 'publicidad_admin_button.dart';
import 'publicidad_controller.dart';
import 'publicidad_tab.dart';

/// Pestaña Portafolio: galería de imágenes (Ad con type: 'gallery').
/// Solo el admin puede subir/editar/eliminar; todos pueden verlas.
/// Cada imagen puede llevar una descripción.
class PortfolioTab extends StatelessWidget {
  const PortfolioTab({
    super.key,
    required this.state,
    required this.esAdmin,
    required this.onReload,
    required this.onUpload,
    required this.onEdit,
    required this.onDelete,
  });

  final LoadableList<GalleryItem> state;
  final bool esAdmin;
  final Future<void> Function() onReload;
  final VoidCallback onUpload;
  final ValueChanged<GalleryItem> onEdit;
  final ValueChanged<GalleryItem> onDelete;

  @override
  Widget build(BuildContext context) {
    return PublicidadTab(
      cargando: state.cargando,
      error: state.error,
      onReload: onReload,
      isEmpty: state.items.isEmpty,
      emptyText: 'No hay imágenes aún',
      adminButton: esAdmin
          ? PublicidadAdminButton(
              icon: Icons.add_photo_alternate,
              label: 'Subir imágenes',
              onPressed: onUpload,
            )
          : null,
      child: GalleryGrid(
        items: state.items,
        onDelete: esAdmin ? (item) => onDelete(item) : null,
        onEdit: esAdmin ? (item) => onEdit(item) : null,
      ),
    );
  }
}