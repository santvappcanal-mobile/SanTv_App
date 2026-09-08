import 'package:flutter/material.dart';
import 'home_hero_banner.dart';
import 'featured_videos_carousel.dart';
import '../publicidad_section.dart';

/// Contenido completo de la pestaña "Inicio".
/// Antes era _buildHomeTab() dentro de home.dart.
class HomeTabContent extends StatelessWidget {
  const HomeTabContent({
    super.key,
    required this.neonColor,
    required this.onOpenAdvertising,
  });

  final Color neonColor;
  final VoidCallback onOpenAdvertising;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeroBanner(neonColor: neonColor),
          const SizedBox(height: 24),
          PublicidadSection(onTap: onOpenAdvertising),
          const SizedBox(height: 24),
          const FeaturedVideosCarousel(),
        ],
      ),
    );
  }
}