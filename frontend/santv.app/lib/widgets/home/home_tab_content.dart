import 'package:flutter/material.dart';
import 'package:santv_app/widgets/live/live_channel_player.dart';
import 'featured_videos_carousel.dart';
import 'citizen_reporter_card.dart';
import '../publicidad_section.dart';
import '../../services/auth_service.dart';

class HomeTabContent extends StatelessWidget {
  const HomeTabContent({
    super.key,
    required this.neonColor,
    required this.onOpenAdvertising,
    required this.authService,
    required this.onOpenLiveTab,
    required this.isActive,
    this.isAdmin = false,
  });

  final Color neonColor;
  final VoidCallback onOpenAdvertising;
  final AuthService authService;

  /// Lleva a la pestaña "En vivo".
  final VoidCallback onOpenLiveTab;

  /// true cuando el Home es la pestaña visible (para pausar el video
  /// cuando el usuario está en otra pestaña o pantalla).
  final bool isActive;

  /// true si el usuario es admin o editor (ve el botón de revisar reportes).
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En vivo arrancando solo; al tocarlo va a la pestaña En vivo.
          LiveChannelPlayer(
            isActive: isActive,
            onTap: onOpenLiveTab,
          ),
          const SizedBox(height: 24),
          // Reportero Ciudadano: reportar, mapa y mis reportes (usuarios y admins)
          CitizenReporterCard(authService: authService, isAdmin: isAdmin),
          const SizedBox(height: 24),
          PublicidadSection(onTap: onOpenAdvertising),
          const SizedBox(height: 24),
          FeaturedVideosCarousel(authService: authService),
        ],
      ),
    );
  }
}