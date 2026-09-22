import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/admin_service.dart';
import '../models/admin_stats.dart';
import 'admin_add_youtube_screen.dart';

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

  Future<void> _abrirAgregarVideo() async {
    final agregado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminAddYoutubeScreen(authService: widget.authService),
      ),
    );
    if (agregado == true) _cargarStats(); // refresca el dashboard al volver
  }

  // NUEVO: abre el diálogo de edición y guarda los cambios en el backend
  Future<void> _editarContenido(TopContentItem item) async {
    final data = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _EditContentDialog(item: item),
    );

    if (data == null) return; // canceló

    final result = await _adminService.updateContent(
      id: item.id,
      title: data['title']!,
      description: data['description']!,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? 'Contenido actualizado'
              : (result.errorMessage ?? 'Error al actualizar'),
        ),
      ),
    );

    if (result.success) _cargarStats(); // refresca el Top 5
  }

  // NUEVO: pide confirmación y elimina el contenido en el backend
  Future<void> _eliminarContenido(TopContentItem item) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        title: const Text(
          'Eliminar contenido',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Seguro que quieres eliminar "${item.title}"? '
          'Esta acción no se puede deshacer.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar != true) return; // canceló

    final result = await _adminService.deleteContent(item.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? 'Contenido eliminado'
              : (result.errorMessage ?? 'Error al eliminar'),
        ),
      ),
    );

    if (result.success) _cargarStats(); // refresca el Top 5
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: neonGreen,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'Agregar video',
          style: TextStyle(color: Colors.black),
        ),
        onPressed: _abrirAgregarVideo,
      ),
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
          const SizedBox(
            height: 80,
          ), // espacio para que el FAB no tape el último item
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
                        errorBuilder: (_, _, _) => _placeholderThumb(),
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
              // NUEVO: lápiz para editar el contenido
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
                tooltip: 'Editar',
                visualDensity: VisualDensity.compact,
                onPressed: () => _editarContenido(item),
              ),
              // NUEVO: papelera para eliminar el contenido
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 20,
                ),
                tooltip: 'Eliminar',
                visualDensity: VisualDensity.compact,
                onPressed: () => _eliminarContenido(item),
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

// NUEVO: diálogo de edición (título y descripción)
class _EditContentDialog extends StatefulWidget {
  const _EditContentDialog({required this.item});

  final TopContentItem item;

  @override
  State<_EditContentDialog> createState() => _EditContentDialogState();
}

class _EditContentDialogState extends State<_EditContentDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.item.title);
    _descCtrl = TextEditingController(text: widget.item.description);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    final title = _titleCtrl.text.trim();
    final description = _descCtrl.text.trim();

    if (title.isEmpty || description.isEmpty) {
      setState(() {
        _validationError = 'El título y la descripción no pueden estar vacíos';
      });
      return;
    }

    Navigator.pop(context, {'title': title, 'description': description});
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white24),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AdminDashboardScreen.neonGreen),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _AdminDashboardScreenState.cardBg,
      title: const Text(
        'Editar contenido',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(color: Colors.white),
              cursorColor: AdminDashboardScreen.neonGreen,
              decoration: _decoration('Título'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              cursorColor: AdminDashboardScreen.neonGreen,
              decoration: _decoration('Descripción'),
            ),
            if (_validationError != null) ...[
              const SizedBox(height: 12),
              Text(
                _validationError!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        ElevatedButton(
          onPressed: _guardar,
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminDashboardScreen.neonGreen,
          ),
          child: const Text('Guardar', style: TextStyle(color: Colors.black)),
        ),
      ],
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