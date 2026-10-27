import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/report.dart';
import '../services/auth_service.dart';
import 'news_map_screen.dart';

/// Detalle de una noticia ciudadana: foto, texto, autor y acceso al mapa.
/// Se usa desde la franja del Home y, más adelante, desde Explorar y Destacados.
class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({
    super.key,
    required this.report,
    required this.authService,
  });

  final Report report;
  final AuthService authService;

  static const _neon = Color(0xFF39FF14);

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final author = report.authorName.isEmpty ? 'un ciudadano' : report.authorName;
    final date = _formatDate(report.createdAt);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 320,
            backgroundColor: const Color(0xFF0B0B0B),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: report.imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => const ColoredBox(
                      color: Colors.black26,
                      child: Icon(Icons.broken_image, color: Colors.white38, size: 48),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xFF0B0B0B)],
                        stops: [0.55, 1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _neon.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          report.category,
                          style: const TextStyle(color: _neon, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text('Noticia ciudadana',
                          style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    report.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.verified, color: _neon, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Reportado por $author'
                          '${report.authorBadge.isNotEmpty ? ' · ${report.authorBadge}' : ''}'
                          '${date.isNotEmpty ? ' · $date' : ''}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    report.description,
                    style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                  ),
                  if (report.address.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, color: Colors.white54, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(report.address,
                              style: const TextStyle(color: Colors.white60)),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NewsMapScreen(authService: authService),
                        ),
                      ),
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Ver en el mapa de noticias'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}