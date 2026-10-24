import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/gallery_item.dart';

/// Tarjeta grande de un servicio del portafolio: foto a todo el ancho,
/// número, título y un botón "Más información". Al tocarla se abre el
/// detalle del servicio. El admin ve además el lápiz y la caneca.
class PortfolioItemCard extends StatelessWidget {
  const PortfolioItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final GalleryItem item;

  /// Posición en la lista (0, 1, 2...), se muestra como "01", "02"...
  final int index;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  static const Color neonGreen = Color(0xFF39FF14);

  @override
  Widget build(BuildContext context) {
    final titulo = item.description.trim().isEmpty
        ? 'Servicio del portafolio'
        : item.description.trim();
    final numero = (index + 1).toString().padLeft(2, '0');

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: neonGreen.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: neonGreen.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: 16 / 11,
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
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.35, 1],
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.92),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: neonGreen.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Text(
                      numero,
                      style: const TextStyle(
                        color: neonGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                if (onEdit != null || onDelete != null)
                  Positioned(
                    top: 10,
                    right: 10,
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
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.fromLTRB(14, 7, 8, 7),
                        decoration: BoxDecoration(
                          color: neonGreen,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Más información',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.black,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
        padding: const EdgeInsets.all(7),
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}