import 'package:flutter/material.dart';
import 'package:santv_app/widgets/live/live_channel_player.dart';
import 'package:santv_app/widgets/live_tab/live_grid_card.dart';
import 'package:santv_app/widgets/live_tab/pulsing_live_dot.dart';

/// Pestaña "En Vivo". Se usa embebida dentro de [Home]
/// (pages/home.dart), como uno de los ítems del IndexedStack.
/// Muestra el canal en vivo permanente arriba (autoplay), y debajo
/// un listado de otras transmisiones/eventos en vivo puntuales.
class LiveTabScreen extends StatelessWidget {
  const LiveTabScreen({
    super.key,
    this.onOpenLive,
    this.isActive = true,
  });

  /// Se llama con el id del live seleccionado, para que Home/el
  /// router navegue a LiveScreen con ese contenido.
  final void Function(String liveId)? onOpenLive;

  /// true cuando la pestaña En vivo es la visible. Si es false el
  /// video se pausa (evita que suene mientras el usuario está en
  /// otra pestaña, ya que el IndexedStack mantiene todo construido).
  final bool isActive;

  // Datos de ejemplo. Reemplaza por tu lista real (backend/socket) de
  // eventos en vivo puntuales (LiveEvent), aparte del canal 24/7.
  static const _liveStreams = [
    {
      'id': 'live_1',
      'title': 'Liga Local - Final',
      'streamer': 'SAN TV Deportes',
      'viewers': 3421,
    },
    {
      'id': 'live_2',
      'title': 'Noticias de la tarde',
      'streamer': 'SAN TV Noticias',
      'viewers': 1288,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final neonColor = Theme.of(context).colorScheme.primary;
    final rest = _liveStreams.skip(1).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              PulsingLiveDot(),
              SizedBox(width: 8),
              Text(
                'Canal en vivo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Canal permanente de SAN TV, reproduciéndose en autoplay.
          LiveChannelPlayer(isActive: isActive, showLiveBadge: false),

          const SizedBox(height: 24),
          const Text(
            'Más transmisiones',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rest.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final stream = rest[index];
              return LiveGridCard(
                title: stream['title'] as String,
                viewers: stream['viewers'] as int,
                neonColor: neonColor,
                onTap: () => onOpenLive?.call(stream['id'] as String),
              );
            },
          ),
        ],
      ),
    );
  }
}
