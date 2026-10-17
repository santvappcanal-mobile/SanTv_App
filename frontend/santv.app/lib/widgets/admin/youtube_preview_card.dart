import 'package:flutter/material.dart';

class YoutubePreviewCard extends StatelessWidget {
  const YoutubePreviewCard({
    super.key,
    required this.thumbnailUrl,
    required this.title,
    required this.channelName,
  });

  final String? thumbnailUrl;
  final String? title;
  final String? channelName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              thumbnailUrl ?? '',
              width: 90,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 90,
                height: 60,
                color: Colors.white12,
                child: const Icon(Icons.movie, color: Colors.white38),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  channelName ?? '',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}