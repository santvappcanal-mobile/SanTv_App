import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/report.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';
import 'report_detail_screen.dart';

/// Todos los reportes ciudadanos publicados (aprobados).
///
/// - El admin/editor ve el botón de eliminar en TODOS.
/// - Un usuario normal lo ve solo en los reportes que él envió.
/// La propiedad se averigua cruzando con "Mis reportes", así no hace
/// falta conocer el id del usuario ni cambiar el modelo.
class PublishedReportsScreen extends StatefulWidget {
  const PublishedReportsScreen({
    super.key,
    required this.authService,
    this.isAdmin = false,
  });

  final AuthService authService;
  final bool isAdmin;

  @override
  State<PublishedReportsScreen> createState() => _PublishedReportsScreenState();
}

class _PublishedReportsScreenState extends State<PublishedReportsScreen> {
  static const _neon = Color(0xFF39FF14);

  late final ReportService _service = ReportService(widget.authService);

  List<Report> _reports = [];
  Set<String> _mineIds = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final all = await _service.getPublished();

      // Mis reportes, solo para saber cuáles son míos.
      var mine = <String>{};
      try {
        final result = await _service.getMine();
        mine = result.reports.map((r) => r.id).toSet();
      } on ReportException {
        // Si falla, simplemente no se marcan como míos.
      }

      all.sort((a, b) {
        final da = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final db = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return db.compareTo(da);
      });

      if (!mounted) return;
      setState(() {
        _reports = all;
        _mineIds = mine;
      });
    } on ReportException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isMine(Report r) => _mineIds.contains(r.id);

  bool _canDelete(Report r) => widget.isAdmin || _isMine(r);

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _date(DateTime? d) {
    if (d == null) return '';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  Future<void> _open(Report r) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ReportDetailScreen(
          report: r,
          authService: widget.authService,
          canManage: _isMine(r),
        ),
      ),
    );
    if (changed == true) _load();
  }

  Future<void> _delete(Report r) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Eliminar reporte', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Este reporte está publicado en Noticias. Si lo eliminas, '
          'desaparecerá para todos los usuarios. Esta acción no se puede deshacer.',
          style: TextStyle(color: Colors.white70),
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

    try {
      await _service.delete(r.id);
      if (!mounted) return;
      setState(() => _reports.removeWhere((x) => x.id == r.id));
      _snack('Reporte eliminado');
    } on ReportException catch (e) {
      // Si el servidor lo rechaza (por ejemplo, permisos), se muestra su mensaje.
      _snack(e.message);
    }
  }

  Widget _card(Report r) {
    final mine = _isMine(r);
    final subtitle = [
      if (r.authorName.isNotEmpty) r.authorName,
      if (r.createdAt != null) _date(r.createdAt),
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _open(r),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                child: CachedNetworkImage(
                  imageUrl: r.imageUrl,
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 96,
                    height: 96,
                    color: Colors.black26,
                    child: const Icon(Icons.broken_image, color: Colors.white38),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                      if (mine)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'Tuyo',
                            style: TextStyle(
                                color: _neon, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (_canDelete(r))
                IconButton(
                  tooltip: 'Eliminar',
                  onPressed: () => _delete(r),
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0B),
        foregroundColor: Colors.white,
        title: const Text('Publicados'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _neon))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: _load, child: const Text('Reintentar')),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: _neon,
                  child: _reports.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(
                              child: Text(
                                'Todavía no hay reportes publicados.',
                                style: TextStyle(color: Colors.white60),
                              ),
                            ),
                          ],
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                          children: _reports.map(_card).toList(),
                        ),
                ),
    );
  }
}