import 'package:flutter/material.dart';
import 'package:santv_app/models/gallery_item.dart';
import 'package:santv_app/widgets/common/gallery_grid.dart'
    show GalleryViewerPage;
import 'portfolio_header_card.dart';
import 'portfolio_item_card.dart';
import 'publicidad_admin_button.dart';
import 'publicidad_controller.dart';
import 'publicidad_tab.dart';

/// Pestaña Portafolio: tarjeta de presentación con WhatsApp y galería de
/// imágenes (Ad con type: 'gallery').
/// Solo el admin puede subir/editar/eliminar; todos pueden verlas.
/// Cada imagen puede llevar una descripción que se muestra como título.
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

  void _abrirVisor(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            GalleryViewerPage(items: state.items, initialIndex: index),
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
      // El estado vacío se dibuja dentro del scroll (más abajo) para que la
      // tarjeta de WhatsApp se vea siempre, aunque no haya imágenes.
      isEmpty: false,
      emptyText: '',
      adminButton: esAdmin
          ? PublicidadAdminButton(
              icon: Icons.add_photo_alternate,
              label: 'Subir imágenes',
              onPressed: onUpload,
            )
          : null,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: PortfolioHeaderCard()),
          if (items.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Text(
                    'No hay imágenes aún',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              // Espacio abajo para que el botón "Quiero pautar" no tape
              // las últimas tarjetas.
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = items[index];
                  return PortfolioItemCard(
                    item: item,
                    onTap: () => _abrirVisor(context, index),
                    onEdit: esAdmin ? () => onEdit(item) : null,
                    onDelete: esAdmin ? () => onDelete(item) : null,
                  );
                }, childCount: items.length),
              ),
            ),
        ],
      ),
    );
  }
}