import 'package:flutter/material.dart';
import 'package:santv_app/widgets/live/live_channel_player.dart';
import 'featured_videos_carousel.dart';
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
  });

  final Color neonColor;
  final VoidCallback onOpenAdvertising;
  final AuthService authService;

  /// Lleva a la pestaña "En vivo".
  final VoidCallback onOpenLiveTab;

  /// true cuando el Home es la pestaña visible (para pausar el video
  /// cuando el usuario está en otra pestaña o pantalla).
  final bool isActive;

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
          PublicidadSection(onTap: onOpenAdvertising),
          const SizedBox(height: 24),
          FeaturedVideosCarousel(authService: authService),
        ],
      ),
    );
  }
}
