import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/report.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';
import 'report_create_screen.dart';
import 'report_detail_screen.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  static const _neon = Color(0xFF39FF14);

  late final ReportService _service = ReportService(widget.authService);

  List<Report> _reports = [];
  ReporterStats _stats = const ReporterStats();
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
      final result = await _service.getMine();
      if (!mounted) return;
      setState(() {
        _reports = result.reports;
        _stats = result.stats;
      });
    } on ReportException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  (String, Color) _statusInfo(Report r) {
    if (r.isApproved) return ('Publicado', _neon);
    if (r.isRejected) return ('Rechazado', Colors.redAccent);
    return ('En revisión', Colors.orangeAccent);
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _open(Report r) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ReportDetailScreen(
          report: r,
          authService: widget.authService,
          canManage: true,
        ),
      ),
    );
    if (changed == true) _load();
  }

  Future<void> _edit(Report r) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ReportCreateScreen(authService: widget.authService, report: r),
      ),
    );
    if (saved == true) _load();
  }

  Future<void> _delete(Report r) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Eliminar reporte', style: TextStyle(color: Colors.white)),
        content: Text(
          r.isApproved
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

    try {
      await _service.delete(r.id);
      if (!mounted) return;
      setState(() => _reports.removeWhere((x) => x.id == r.id));
      _snack('Reporte eliminado');
    } on ReportException catch (e) {
      _snack(e.message);
    }
  }

  Widget _reportCard(Report r) {
    final (label, color) = _statusInfo(r);
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
                      Text(r.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(label,
                          style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                      if (r.isRejected && r.rejectionReason.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(r.rejectionReason,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ),
                    ],
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white54),
                color: const Color(0xFF1A1A1A),
                onSelected: (value) {
                  if (value == 'edit') {
                    _edit(r);
                  } else {
                    _delete(r);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(
                      r.isRejected ? 'Editar y reenviar' : 'Editar',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
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
        title: const Text('Mis reportes'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _neon,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.campaign),
        label: const Text('Reportar'),
        onPressed: () async {
          final sent = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => ReportCreateScreen(authService: widget.authService),
            ),
          );
          if (sent == true) _load();
        },
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
                        Text(_error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: _load, child: const Text('Reintentar')),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: _neon,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                    children: [
                      _StatsCard(stats: _stats),
                      const SizedBox(height: 16),
                      if (_reports.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              'Todavía no has enviado reportes.\n¡Cuéntale a tu comunidad qué está pasando!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white60),
                            ),
                          ),
                        )
                      else
                        ..._reports.map(_reportCard),
                    ],
                  ),
                ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});

  final ReporterStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF39FF14).withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Expanded(child: _stat('${stats.points}', 'Puntos')),
          Expanded(child: _stat('${stats.approved}', 'Publicados')),
          Expanded(
            child: _stat(
              stats.badge.isEmpty ? '—' : stats.badge,
              'Insignia',
              small: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, {bool small = false}) {
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF39FF14),
            fontSize: small ? 14 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }
}