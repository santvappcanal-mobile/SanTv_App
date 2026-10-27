import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/report.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  static const _neon = Color(0xFF39FF14);

  late final ReportService _service = ReportService(widget.authService);

  List<Report> _reports = [];
  final Set<String> _busy = {};
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
      final data = await _service.getPending();
      if (!mounted) return;
      setState(() => _reports = data);
    } on ReportException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _approve(Report r, {bool useAiTitle = false}) async {
    setState(() => _busy.add(r.id));
    try {
      await _service.approve(
        r.id,
        title: useAiTitle && r.ai.suggestedTitle.isNotEmpty ? r.ai.suggestedTitle : null,
        category: useAiTitle && r.ai.suggestedCategory.isNotEmpty ? r.ai.suggestedCategory : null,
      );
      if (!mounted) return;
      setState(() => _reports.removeWhere((x) => x.id == r.id));
      _snack('Reporte publicado en Noticias');
    } on ReportException catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _busy.remove(r.id));
    }
  }

  Future<void> _reject(Report r) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Rechazar reporte', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          maxLength: 300,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Motivo (se le muestra al usuario)',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Rechazar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null) return;

    setState(() => _busy.add(r.id));
    try {
      await _service.reject(r.id, reason: reason);
      if (!mounted) return;
      setState(() => _reports.removeWhere((x) => x.id == r.id));
      _snack('Reporte rechazado');
    } on ReportException catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _busy.remove(r.id));
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0B),
        foregroundColor: Colors.white,
        title: Text('Reportes por revisar${_reports.isEmpty ? '' : ' (${_reports.length})'}'),
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
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
              : _reports.isEmpty
                  ? const Center(
                      child: Text('No hay reportes pendientes 🎉',
                          style: TextStyle(color: Colors.white70, fontSize: 16)),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: _neon,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _reports.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (_, i) => _ReportReviewCard(
                          report: _reports[i],
                          busy: _busy.contains(_reports[i].id),
                          onApprove: () => _approve(_reports[i]),
                          onApproveWithAi: () => _approve(_reports[i], useAiTitle: true),
                          onReject: () => _reject(_reports[i]),
                        ),
                      ),
                    ),
    );
  }
}

class _ReportReviewCard extends StatelessWidget {
  const _ReportReviewCard({
    required this.report,
    required this.busy,
    required this.onApprove,
    required this.onApproveWithAi,
    required this.onReject,
  });

  final Report report;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onApproveWithAi;
  final VoidCallback onReject;

  static const _neon = Color(0xFF39FF14);

  Color _riskColor(int score) {
    if (score >= 60) return Colors.redAccent;
    if (score >= 30) return Colors.orangeAccent;
    return _neon;
  }

  @override
  Widget build(BuildContext context) {
    final r = report;
    final ai = r.ai;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedNetworkImage(
            imageUrl: r.imageUrl,
            height: 190,
            width: double.infinity,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Container(
              height: 190,
              color: Colors.black26,
              child: const Icon(Icons.broken_image, color: Colors.white38),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.title,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(r.description, style: const TextStyle(color: Colors.white70, height: 1.35)),
                const SizedBox(height: 10),
                Text(
                  '${r.category} · por ${r.authorName.isEmpty ? 'usuario' : r.authorName}'
                  '${r.authorBadge.isNotEmpty ? ' (${r.authorBadge})' : ''}'
                  ' · ${r.authorApproved} aprobados',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                if (r.address.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('📍 ${r.address}',
                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ),
                if (r.nearbyReports > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '⚠️ Hay ${r.nearbyReports} reporte(s) cercanos en las últimas 24 h: '
                      'puede ser el mismo suceso.',
                      style: const TextStyle(color: Colors.orangeAccent, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 12),
                _AiBox(ai: ai, color: _riskColor(ai.suspicionScore)),
                const SizedBox(height: 14),
                if (busy)
                  const Center(child: CircularProgressIndicator(color: _neon))
                else
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onReject,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(color: Colors.redAccent),
                              ),
                              child: const Text('Rechazar'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onApprove,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _neon,
                                foregroundColor: Colors.black,
                              ),
                              child: const Text('Aprobar'),
                            ),
                          ),
                        ],
                      ),
                      if (ai.analyzed && ai.suggestedTitle.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: onApproveWithAi,
                              icon: const Icon(Icons.auto_awesome, size: 18, color: _neon),
                              label: const Text('Aprobar con título de la IA',
                                  style: TextStyle(color: _neon)),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AiBox extends StatelessWidget {
  const _AiBox({required this.ai, required this.color});

  final ReportAnalysis ai;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (!ai.analyzed) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text('La IA no pudo analizar este reporte. Revísalo manualmente.',
            style: TextStyle(color: Colors.white54, fontSize: 12)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              const Text('Análisis de la IA',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('Sospecha ${ai.suspicionScore}/100',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ai.suspicionScore / 100,
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          if (ai.suspicionReason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(ai.suspicionReason, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          ],
          if (ai.suggestedTitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Título sugerido: ${ai.suggestedTitle}',
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
          if (ai.summary.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(ai.summary, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}
