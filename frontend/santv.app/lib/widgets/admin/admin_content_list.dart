import 'package:flutter/material.dart';
import '../../models/admin_stats.dart';
import 'content_item_card.dart';

class AdminContentList extends StatelessWidget {
  const AdminContentList({
    super.key,
    required this.loading,
    required this.error,
    required this.items,
    required this.onRefresh,
    required this.onEdit,
    required this.onDelete,
    this.accentColor = const Color(0xFF39FF14),
  });

  final bool loading;
  final String? error;
  final List<TopContentItem> items;
  final Future<void> Function() onRefresh;
  final ValueChanged<TopContentItem> onEdit;
  final ValueChanged<TopContentItem> onDelete;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(child: CircularProgressIndicator(color: accentColor));
    }
    if (error != null) return _errorView();
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Aún no hay videos subidos',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }
    return RefreshIndicator(
      color: accentColor,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) => ContentItemCard(
          item: items[i],
          accentColor: accentColor,
          onEdit: () => onEdit(items[i]),
          onDelete: () => onDelete(items[i]),
        ),
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
            const SizedBox(height: 12),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRefresh,
              style: ElevatedButton.styleFrom(backgroundColor: accentColor),
              child: const Text(
                'Reintentar',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}