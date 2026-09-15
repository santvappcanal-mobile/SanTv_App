import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/live_viewer.dart';
import '../../services/live_viewer_service.dart';

/// Chip de vidrio que muestra, en tiempo real, el número de personas
/// viendo la transmisión junto con una pila de avatares.
///
/// Se conecta a [LiveViewerService] por streams (`viewerCountStream`,
/// `viewersListStream`), con el valor actual (`currentCount`,
/// `currentViewers`) como dato inicial mientras llega el primer evento.
class LiveViewersBar extends StatelessWidget {
  const LiveViewersBar({
    super.key,
    required this.service,
    this.maxAvatars = 3,
  });

  final LiveViewerService service;
  final int maxAvatars;

  static const Color _neonGreen = Color(0xFF39FF14);

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: service.viewerCountStream,
      initialData: service.currentCount,
      builder: (context, countSnapshot) {
        final count = countSnapshot.data ?? 0;
        return StreamBuilder<List<LiveViewer>>(
          stream: service.viewersListStream,
          initialData: service.currentViewers,
          builder: (context, viewersSnapshot) {
            final viewers = viewersSnapshot.data ?? const [];
            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (viewers.isNotEmpty)
                        _AvatarStack(viewers: viewers, maxAvatars: maxAvatars),
                      if (viewers.isNotEmpty) const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: _neonGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_formatCount(count)} viendo',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.viewers, required this.maxAvatars});

  final List<LiveViewer> viewers;
  final int maxAvatars;

  @override
  Widget build(BuildContext context) {
    final shown = viewers.take(maxAvatars).toList();
    const double size = 20;
    const double overlap = 12;

    return SizedBox(
      width: overlap * (shown.length - 1) + size,
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * overlap,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: size / 2,
                  backgroundColor: Colors.white24,
                  backgroundImage: shown[i].avatarUrl != null
                      ? CachedNetworkImageProvider(shown[i].avatarUrl!)
                      : null,
                  child: shown[i].avatarUrl == null
                      ? Text(
                          shown[i].name.isNotEmpty
                              ? shown[i].name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        )
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}