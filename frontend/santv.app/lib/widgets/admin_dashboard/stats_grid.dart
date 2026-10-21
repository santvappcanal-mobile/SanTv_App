import 'package:flutter/material.dart';
import '../../models/admin_stats.dart';
import 'stat_card.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({
    super.key,
    required this.stats,
    required this.onUsuarios,
    required this.onContenido,
    required this.onAnuncios,
  });

  final AdminStats stats;
  final VoidCallback onUsuarios;
  final VoidCallback onContenido;
  final VoidCallback onAnuncios;

  @override
  Widget build(BuildContext context) {
    final cards = [
      StatCardData(
        'Usuarios registrados',
        '${stats.totalUsers}',
        Icons.people,
        onTap: onUsuarios,
      ),
      StatCardData(
        'Contenido',
        '${stats.totalContent}',
        Icons.movie,
        subtitle: '${stats.activeContent} activo',
        onTap: onContenido,
      ),
      StatCardData(
        'Vistas totales',
        '${stats.totalViews}',
        Icons.remove_red_eye,
      ),
      StatCardData(
        'Anuncios',
        '${stats.totalAds}',
        Icons.ondemand_video,
        subtitle: '${stats.activeAds} activos',
        onTap: onAnuncios,
      ),
      StatCardData(
        'Eventos en vivo',
        '${stats.totalLiveEvents}',
        Icons.live_tv,
        subtitle: '${stats.liveNow} en vivo ahora',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (_, i) => StatCard(data: cards[i]),
    );
  }
}