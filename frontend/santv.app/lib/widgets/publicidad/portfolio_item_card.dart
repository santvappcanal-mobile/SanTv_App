import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/gallery_item.dart';

/// Tarjeta de una imagen del portafolio: foto, título con detalle verde
/// y, solo para el admin, los botones de editar y eliminar.
class PortfolioItemCard extends StatelessWidget {
  const PortfolioItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final GalleryItem item;
  final VoidCallback onTap;

  /// Si no es null (admin), muestra el lápiz.
  final VoidCallback? onEdit;

  /// Si no es null (admin), muestra la caneca.
  final VoidCallback? onDelete;

  static const Color neonGreen = Color(0xFF39FF14);

  @override
  Widget build(BuildContext context) {
    final titulo = item.description.trim();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: item.mediaUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: neonGreen,
                  ),
                ),
                errorWidget: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
              if (titulo.isNotEmpty) _TituloInferior(texto: titulo),
              if (onEdit != null || onDelete != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null)
                        _BotonAdmin(
                          icon: Icons.edit,
                          color: neonGreen,
                          onTap: onEdit!,
                        ),
                      if (onEdit != null && onDelete != null)
                        const SizedBox(width: 6),
                      if (onDelete != null)
                        _BotonAdmin(
                          icon: Icons.delete,
                          color: Colors.redAccent,
                          onTap: onDelete!,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TituloInferior extends StatelessWidget {
  const _TituloInferior({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 36, 12, 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.55),
              Colors.black.withValues(alpha: 0.92),
            ],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 3,
              height: 30,
              decoration: BoxDecoration(
                color: PortfolioItemCard.neonGreen,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                texto,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonAdmin extends StatelessWidget {
  const _BotonAdmin({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}