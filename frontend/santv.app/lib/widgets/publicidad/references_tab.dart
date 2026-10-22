import 'package:flutter/material.dart';
import 'package:santv_app/models/reference_video_item.dart';
import 'publicidad_admin_button.dart';
import 'publicidad_controller.dart';
import 'publicidad_tab.dart';
import 'reference_video_card.dart';

/// Pestaña Referencias: videos subidos a Cloudinary.
/// Solo el admin/editor puede subir, editar y eliminar; todos pueden verlos.
class ReferencesTab extends StatelessWidget {
  const ReferencesTab({
    super.key,
    required this.state,
    required this.esAdmin,
    required this.onReload,
    required this.onAdd,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final LoadableList<ReferenceVideoItem> state;
  final bool esAdmin;
  final Future<void> Function() onReload;
  final VoidCallback onAdd;
  final ValueChanged<ReferenceVideoItem> onOpen;
  final ValueChanged<ReferenceVideoItem> onEdit;
  final ValueChanged<ReferenceVideoItem> onDelete;

  @override
  Widget build(BuildContext context) {
    return PublicidadTab(
      cargando: state.cargando,
      error: state.error,
      onReload: onReload,
      isEmpty: state.items.isEmpty,
      emptyText: 'No hay videos de referencia aún',
      adminButton: esAdmin
          ? PublicidadAdminButton(
              icon: Icons.video_call,
              label: 'Agregar video',
              onPressed: onAdd,
            )
          : null,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        itemCount: state.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = state.items[index];
          return ReferenceVideoCard(
            item: item,
            esAdmin: esAdmin,
            onTap: () => onOpen(item),
            onEdit: () => onEdit(item),
            onDelete: () => onDelete(item),
          );
        },
      ),
    );
  }
}