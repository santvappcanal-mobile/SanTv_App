import 'package:flutter/material.dart';
import '../../services/live_viewer_service.dart';
import 'live_viewers_bar.dart';

/// Fila de metadatos bajo el título del live: rating, año,
/// espectadores en vivo (widget aparte) y calidad HD.
class LiveMetaRow extends StatelessWidget {
  const LiveMetaRow({
    super.key,
    required this.rating,
    required this.year,
    required this.viewerService,
  });

  final double rating;
  final int year;
  final LiveViewerService viewerService;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 18),
            const SizedBox(width: 4),
            Text('$rating', style: const TextStyle(color: Colors.white)),
          ],
        ),
        Text('$year', style: const TextStyle(color: Colors.white70)),
        LiveViewersBar(service: viewerService),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'HD',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ),
      ],
    );
  }
}