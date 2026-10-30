import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/report.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';
import 'news_map_screen.dart';
import 'report_create_screen.dart';

/// Detalle de una noticia ciudadana: foto, texto, autor y acceso al mapa.
/// Se usa desde la franja del Home, Mis reportes y las notificaciones.
///
/// Con [canManage] (el reporte es del usuario) aparece el menú para editarlo
/// o eliminarlo. Si cambia algo, la pantalla se cierra devolviendo `true`
/// para que la lista que la abrió se recargue.
class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({
    super.key,
    required this.report,
    required this.authService,
    this.canManage = false,
  });

  final Report report;
  final AuthService authService;
  final bool canManage;

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  static const _neon = Color(0xFF39FF14);

  late final ReportService _service = ReportService(widget.authService);
  bool _busy = false;

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _edit() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ReportCreateScreen(
          authService: widget.authService,
          report: widget.report,
        ),
      ),
    );
    if (saved == true && mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final report = widget.report;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Eliminar reporte', style: TextStyle(color: Colors.white)),
        content: Text(
          report.isApproved
              ? 'Este reporte está publicado en Noticias. Si lo eliminas, también '
                  'desaparecerá de allí. Esta acción no se puede deshacer.'
              : 'Esta acción no se puede deshacer.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _busy = true);
    try {
      await _service.delete(report.id);
      _snack('Reporte eliminado');
      if (mounted) Navigator.pop(context, true);
    } on ReportException catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final author = report.authorName.isEmpty ? 'un ciudadano' : report.authorName;
    final date = _formatDate(report.createdAt);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 320,
            backgroundColor: const Color(0xFF0B0B0B),
            foregroundColor: Colors.white,
            actions: [
              if (widget.canManage)
                _busy
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: _neon),
                        ),
                      )
                    : PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        color: const Color(0xFF1A1A1A),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _edit();
                          } else {
                            _delete();
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(
                              report.isRejected ? 'Editar y reenviar' : 'Editar',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Eliminar',
                                style: TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: report.imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => const ColoredBox(
                      color: Colors.black26,
                      child: Icon(Icons.broken_image, color: Colors.white38, size: 48),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xFF0B0B0B)],
                        stops: [0.55, 1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _neon.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          report.category,
                          style: const TextStyle(color: _neon, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text('Noticia ciudadana',
                          style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    report.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.verified, color: _neon, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Reportado por $author'
                          '${report.authorBadge.isNotEmpty ? ' · ${report.authorBadge}' : ''}'
                          '${date.isNotEmpty ? ' · $date' : ''}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    report.description,
                    style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                  ),
                  if (report.address.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, color: Colors.white54, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(report.address,
                              style: const TextStyle(color: Colors.white60)),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NewsMapScreen(authService: widget.authService),
                        ),
                      ),
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Ver en el mapa de noticias'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}