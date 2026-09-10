import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/admin_service.dart';
import '../models/admin_stats.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key, required this.authService});

  final AuthService authService;

  static const Color neonGreen = Color(0xFF39FF14);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final AdminService _adminService;

  bool _cargando = true;
  String? _error;
  AdminStats? _stats;

  static const Color neonGreen = AdminDashboardScreen.neonGreen;
  static const Color cardBg = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _adminService = AdminService(authService: widget.authService);
    _cargarStats();
  }

  Future<void> _cargarStats() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    final result = await _adminService.getDashboardStats();

    if (!mounted) return;

    setState(() {
      _cargando = false;
      if (result.success) {
        _stats = result.stats;
      } else {
        _error = result.errorMessage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargando ? null : _cargarStats,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator(color: neonGreen));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _cargarStats,
                style: ElevatedButton.styleFrom(backgroundColor: neonGreen),
                child: const Text(
                  'Reintentar',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final stats = _stats!;

    return RefreshIndicator(
      color: neonGreen,
      onRefresh: _cargarStats,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatsGrid(stats),
          const SizedBox(height: 24),
          _buildSectionTitle('Contenido por tipo'),
          const SizedBox(height: 12),
          _buildContentByType(stats.contentByType),
          const SizedBox(height: 24),
          _buildSectionTitle('Usuarios por rol'),
          const SizedBox(height: 12),
          _buildUsersByRole(stats.usersByRole),
          const SizedBox(height: 24),
          _buildSectionTitle('Top 5 contenido más visto'),
          const SizedBox(height: 12),
          _buildTopContent(stats.topContent),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(AdminStats stats) {
    final cards = [
      _StatCardData(
        'Usuarios',
        '${stats.totalUsers}',
        '${stats.activeUsers} activos',
        Icons.people,
      ),
      _StatCardData(
        'Contenido',
        '${stats.totalContent}',
        '${stats.activeContent} activo',
        Icons.movie,
      ),
      _StatCardData(
        'Vistas totales',
        '${stats.totalViews}',
        '',
        Icons.remove_red_eye,
      ),
      _StatCardData(
        'Anuncios',
        '${stats.totalAds}',
        '${stats.activeAds} activos',
        Icons.ondemand_video,
      ),
      _StatCardData(
        'Eventos en vivo',
        '${stats.totalLiveEvents}',
        '${stats.liveNow} en vivo ahora',
        Icons.live_tv,
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
      itemBuilder: (context, index) => _StatCard(data: cards[index]),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildContentByType(ContentByType byType) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MiniStat(label: 'Películas', value: byType.movie),
          _MiniStat(label: 'Series', value: byType.series),
          _MiniStat(label: 'Documentales', value: byType.documentary),
        ],
      ),
    );
  }

  Widget _buildUsersByRole(Map<String, int> byRole) {
    if (byRole.isEmpty) {
      return const Text('Sin datos', style: TextStyle(color: Colors.white54));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: byRole.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key, style: const TextStyle(color: Colors.white70)),
                Text(
                  '${entry.value}',
                  style: const TextStyle(
                    color: neonGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopContent(List<TopContentItem> topContent) {
    if (topContent.isEmpty) {
      return const Text(
        'Aún no hay vistas registradas',
        style: TextStyle(color: Colors.white54),
      );
    }

    return Column(
      children: topContent.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: item.thumbnailUrl.isNotEmpty
                    ? Image.network(
                        item.thumbnailUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderThumb(),
                      )
                    : _placeholderThumb(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.type,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.remove_red_eye, color: neonGreen, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${item.views}',
                    style: const TextStyle(color: neonGreen),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _placeholderThumb() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.white12,
      child: const Icon(Icons.movie, color: Colors.white38, size: 20),
    );
  }
}

class _StatCardData {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;

  const _StatCardData(this.label, this.value, this.subtitle, this.icon);
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _AdminDashboardScreenState.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, color: AdminDashboardScreen.neonGreen, size: 22),
          const Spacer(),
          Text(
            data.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            data.label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          if (data.subtitle.isNotEmpty)
            Text(
              data.subtitle,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            color: AdminDashboardScreen.neonGreen,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
