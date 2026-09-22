import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/content.dart';

class ExploreCard extends StatelessWidget {
  const ExploreCard({
    super.key,
    required this.accentColor,
    required this.content,
    required this.onTap,
  });

  final Color accentColor;
  final ContentItem content;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.03),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: content.thumbnailUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: Image.network(
                              content.thumbnailUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, _, _) => Center(
                                child: Icon(
                                  Icons.play_circle_outline,
                                  size: 40,
                                  color: accentColor.withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.play_circle_outline,
                              size: 40,
                              color: accentColor.withValues(alpha: 0.9),
                            ),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.visibility,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${content.views} vistas',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
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
