import 'package:flutter/material.dart';
import '../../models/admin_stats.dart';

class ContentItemCard extends StatelessWidget {
  const ContentItemCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    this.accentColor = const Color(0xFF39FF14),
  });

  final TopContentItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Color accentColor;

  Widget _placeholder() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.white12,
      child: const Icon(Icons.movie, color: Colors.white38, size: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: item.thumbnailUrl.isNotEmpty
                ? Image.network(
                    item.thumbnailUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.type,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.remove_red_eye, color: accentColor, size: 16),
          const SizedBox(width: 4),
          Text('${item.views}', style: TextStyle(color: accentColor)),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
            tooltip: 'Editar',
            visualDensity: VisualDensity.compact,
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.redAccent,
              size: 20,
            ),
            tooltip: 'Eliminar',
            visualDensity: VisualDensity.compact,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}