import 'package:flutter/material.dart';
import '../../models/admin_stats.dart';
import 'dashboard_style.dart';

class TopContentList extends StatelessWidget {
  const TopContentList({
    super.key,
    required this.items,
    required this.onEdit,
    required this.onDelete,
  });

  final List<TopContentItem> items;
  final void Function(TopContentItem) onEdit;
  final void Function(TopContentItem) onDelete;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text(
        'Aún no hay vistas registradas',
        style: TextStyle(color: Colors.white54),
      );
    }
    return Column(
      children: items
          .map(
            (i) => TopContentCard(
              item: i,
              onEdit: () => onEdit(i),
              onDelete: () => onDelete(i),
            ),
          )
          .toList(),
    );
  }
}

class TopContentCard extends StatelessWidget {
  const TopContentCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final TopContentItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Widget _placeholder() => Container(
    width: 50,
    height: 50,
    color: Colors.white12,
    child: const Icon(Icons.movie, color: Colors.white38, size: 20),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCardBg,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.type,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.remove_red_eye, color: kNeonGreen, size: 16),
          const SizedBox(width: 4),
          Text('${item.views}', style: const TextStyle(color: kNeonGreen)),
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