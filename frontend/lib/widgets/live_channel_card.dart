import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'live_badge.dart';

class LiveChannelCard extends StatelessWidget {
  final String nombre;
  final String? thumbnail;
  final bool destacado;
  final VoidCallback onTap;

  const LiveChannelCard({
    super.key,
    required this.nombre,
    required this.onTap,
    this.thumbnail,
    this.destacado = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: destacado
              ? Border.all(color: const Color(0xFF00E676), width: 2)
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: thumbnail != null
                    ? CachedNetworkImage(
                        imageUrl: thumbnail!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: Colors.grey[850]),
                        errorWidget: (_, __, ___) =>
                            Container(color: Colors.grey[850], child: const Icon(Icons.tv)),
                      )
                    : Container(color: Colors.grey[850], child: const Icon(Icons.tv)),
              ),
              Container(
                width: double.infinity,
                color: const Color(0xFF1E1E1E),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LiveBadge(),
                    const SizedBox(height: 6),
                    Text(
                      nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
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