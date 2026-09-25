import 'package:flutter/material.dart';
import 'home_hero_banner.dart';
import 'featured_videos_carousel.dart';
import '../publicidad_section.dart';
import '../../services/auth_service.dart';

class HomeTabContent extends StatelessWidget {
  const HomeTabContent({
    super.key,
    required this.neonColor,
    required this.onOpenAdvertising,
    required this.authService,
    required this.onOpenLive,
  });

  final Color neonColor;
  final VoidCallback onOpenAdvertising;
  final AuthService authService;
  final void Function([String liveId]) onOpenLive;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => onOpenLive(),
            child: HomeHeroBanner(neonColor: neonColor),
          ),
          const SizedBox(height: 24),
          PublicidadSection(onTap: onOpenAdvertising),
          const SizedBox(height: 24),
          FeaturedVideosCarousel(authService: authService),
        ],
      ),
    );
  }
}