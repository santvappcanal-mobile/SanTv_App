import 'package:flutter/material.dart';
import '../../models/admin_stats.dart';
import 'content_by_type_card.dart';
import 'dashboard_style.dart';
import 'section_title.dart';
import 'stats_grid.dart';
import 'top_content_list.dart';
import 'users_by_role_card.dart';

class DashboardBody extends StatelessWidget {
  const DashboardBody({
    super.key,
    required this.stats,
    required this.onRefresh,
    required this.onUsuarios,
    required this.onContenido,
    required this.onAnuncios,
    required this.onEdit,
    required this.onDelete,
  });

  final AdminStats stats;
  final Future<void> Function() onRefresh;
  final VoidCallback onUsuarios;
  final VoidCallback onContenido;
  final VoidCallback onAnuncios;
  final void Function(TopContentItem) onEdit;
  final void Function(TopContentItem) onDelete;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: kNeonGreen,
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StatsGrid(
            stats: stats,
            onUsuarios: onUsuarios,
            onContenido: onContenido,
            onAnuncios: onAnuncios,
          ),
          const SectionTitle('Contenido por tipo'),
          ContentByTypeCard(byType: stats.contentByType),
          const SectionTitle('Usuarios por rol'),
          UsersByRoleCard(byRole: stats.usersByRole),
          const SectionTitle('Top 5 contenido más visto'),
          TopContentList(
            items: stats.topContent,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}