import 'package:flutter/material.dart';
import '../../widgets/live_tab/pulsing_live_dot.dart';
import '../../widgets/live_tab/featured_live_card.dart';
import '../../widgets/live_tab/live_grid_card.dart';

/// Pestaña "En Vivo". Se usa embebida dentro de [Home]
/// (pages/home.dart), como uno de los ítems del IndexedStack.
/// Muestra el listado de transmisiones activas en este momento.
/// Al tocar una tarjeta, se navega a LiveScreen con el detalle.
class LiveTabScreen extends StatelessWidget {
  const LiveTabScreen({super.key, this.onOpenLive});

  /// Se llama con el id del live seleccionado, para que Home/el
  /// router navegue a LiveScreen con ese contenido.
  final void Function(String liveId)? onOpenLive;

  // Datos de ejemplo. Reemplaza por tu lista real (backend/socket).
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
    {
      'id': 'live_3',
      'title': 'Torneo Gaming Regional',
      'streamer': 'SAN Gaming',
      'viewers': 942,
    },
    {
      'id': 'live_4',
      'title': 'Concierto en vivo',
      'streamer': 'SAN Música',
      'viewers': 610,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final neonColor = Theme.of(context).colorScheme.primary;
    final featured = _liveStreams.first;
    final rest = _liveStreams.skip(1).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              PulsingLiveDot(),
              SizedBox(width: 8),
              Text(
                'En vivo ahora',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Transmisión destacada (la más vista)
          FeaturedLiveCard(
            title: featured['title'] as String,
            streamer: featured['streamer'] as String,
            viewers: featured['viewers'] as int,
            neonColor: neonColor,
            onTap: () => onOpenLive?.call(featured['id'] as String),
          ),

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