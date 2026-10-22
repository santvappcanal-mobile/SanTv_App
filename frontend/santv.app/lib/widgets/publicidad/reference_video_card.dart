import 'package:flutter/material.dart';
import 'package:santv_app/models/reference_video_item.dart';

const _neon = Color(0xFF39FF14);

/// Tarjeta de un video de referencia: miniatura, botón de play,
/// título y descripción. El admin ve los botones de editar y eliminar.
class ReferenceVideoCard extends StatelessWidget {
  const ReferenceVideoCard({
    super.key,
    required this.item,
    required this.esAdmin,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final ReferenceVideoItem item;
  final bool esAdmin;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Miniatura (fotograma del video) con respaldo si falla
              Image.network(
                item.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFF1A1A1A),
                  child: const Icon(
                    Icons.videocam_rounded,
                    color: Colors.white24,
                    size: 56,
                  ),
                ),
              ),
              // Degradado inferior para que se lea el título
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
              // Botón de play al centro
              Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: _neon, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: _neon,
                    size: 36,
                  ),
                ),
              ),
              // Título y descripción
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Editar y eliminar (solo admin/editor)
              if (esAdmin)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CircleAction(
                        icon: Icons.edit_outlined,
                        color: _neon,
                        onTap: onEdit,
                      ),
                      const SizedBox(width: 8),
                      _CircleAction(
                        icon: Icons.delete_outline,
                        color: Colors.redAccent,
                        onTap: onDelete,
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

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}