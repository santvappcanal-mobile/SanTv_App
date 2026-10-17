import 'package:flutter/material.dart';

class AdAdminCard extends StatelessWidget {
  const AdAdminCard({
    super.key,
    required this.ad,
    required this.onToggle,
    required this.onDelete,
    this.accentColor = const Color(0xFF39FF14),
  });

  final Map<String, dynamic> ad;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final url = (ad['mediaUrl'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ad['type'] != 'video' && url.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                url,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(
                  height: 160,
                  child: Center(
                    child: Icon(Icons.broken_image, color: Colors.white38),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (ad['title'] ?? 'Sin título').toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${ad['impressions'] ?? 0} vistas · ${ad['clicks'] ?? 0} clics',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: ad['isActive'] == true,
                  activeThumbColor: accentColor,
                  onChanged: onToggle,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}