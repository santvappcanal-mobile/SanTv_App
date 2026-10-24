import 'package:flutter/material.dart';
import 'package:santv_app/models/gallery_item.dart';
import 'package:santv_app/widgets/common/gallery_grid.dart'
    show GalleryViewerPage;
import 'portfolio_item_card.dart';
import 'portfolio_service_sheet.dart';
import 'publicidad_admin_button.dart';
import 'publicidad_controller.dart';
import 'publicidad_tab.dart';

/// Pestaña Portafolio: lista de servicios (Ad con type: 'gallery').
/// Al tocar uno se abre su detalle con el botón de WhatsApp.
/// Solo el admin puede subir/editar/eliminar; todos pueden verlos.
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

  void _abrirServicio(BuildContext context, GalleryItem item, int index) {
    showPortfolioServiceSheet(
      context,
      item: item,
      onVerImagen: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              GalleryViewerPage(items: state.items, initialIndex: index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = state.items;

    return PublicidadTab(
      cargando: state.cargando,
      error: state.error,
      onReload: onReload,
      isEmpty: items.isEmpty,
      emptyText: 'No hay imágenes aún',
      adminButton: esAdmin
          ? PublicidadAdminButton(
              icon: Icons.add_photo_alternate,
              label: 'Subir imágenes',
              onPressed: onUpload,
            )
          : null,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        // Espacio abajo para que el botón "Quiero pautar" no tape la última.
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 100),
        itemCount: items.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) return const _Encabezado();
          final index = i - 1;
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PortfolioItemCard(
              item: item,
              index: index,
              onTap: () => _abrirServicio(context, item, index),
              onEdit: esAdmin ? () => onEdit(item) : null,
              onDelete: esAdmin ? () => onDelete(item) : null,
            ),
          );
        },
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(4, 8, 4, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nuestros servicios',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Toca uno para conocer más y contactarnos.',
            style: TextStyle(color: Colors.white54, fontSize: 13.5),
          ),
        ],
      ),
    );
  }
}