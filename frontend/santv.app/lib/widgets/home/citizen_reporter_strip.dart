import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/report.dart';
import '../../pages/admin_reports_screen.dart';
import '../../pages/my_reports_screen.dart';
import '../../pages/news_map_screen.dart';
import '../../pages/report_create_screen.dart';
import '../../pages/report_detail_screen.dart';
import '../../services/auth_service.dart';
import '../../services/report_service.dart';

/// Franja "Tu comunidad cuenta" para el Home.
/// Primero va la burbuja para reportar (con un latido suave) y luego las
/// últimas noticias ciudadanas aprobadas, como si fueran historias.
class CitizenReporterStrip extends StatefulWidget {
  const CitizenReporterStrip({
    super.key,
    required this.authService,
    this.isAdmin = false,
  });

  final AuthService authService;
  final bool isAdmin;

  @override
  State<CitizenReporterStrip> createState() => _CitizenReporterStripState();
}

class _CitizenReporterStripState extends State<CitizenReporterStrip>
    with SingleTickerProviderStateMixin {
  static const _neon = Color(0xFF39FF14);
  static const _cyan = Color(0xFF00E5FF);
  static const _ringGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_neon, _cyan],
  );

  late final ReportService _service = ReportService(widget.authService);
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  List<Report> _reports = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await _service.getMap();
      if (!mounted) return;
      setState(() => _reports = data.take(10).toList());
    } on ReportException {
      // Si falla, la franja queda solo con la burbuja de reportar.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const SizedBox(height: 12),
        SizedBox(
          height: 104,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              _ReportBubble(
                pulse: _pulse,
                onTap: () => _open(ReportCreateScreen(authService: widget.authService)),
              ),
              if (_loading)
                ...List.generate(3, (_) => const _SkeletonBubble())
              else
                ..._reports.map(
                  (r) => _StoryBubble(
                    report: r,
                    onTap: () => _open(
                      ReportDetailScreen(report: r, authService: widget.authService),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (!_loading && _reports.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Sé el primero en contar qué pasa en tu comunidad.',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(color: _neon, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        const Text(
          'TU COMUNIDAD CUENTA',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
          ),
        ),
        const Spacer(),
        _HeaderIcon(
          icon: Icons.map_outlined,
          tooltip: 'Mapa de noticias',
          onTap: () => _open(NewsMapScreen(authService: widget.authService)),
        ),
        _HeaderIcon(
          icon: Icons.history,
          tooltip: 'Mis reportes',
          onTap: () => _open(MyReportsScreen(authService: widget.authService)),
        ),
        if (widget.isAdmin)
          _HeaderIcon(
            icon: Icons.fact_check_outlined,
            tooltip: 'Revisar reportes',
            onTap: () => _open(AdminReportsScreen(authService: widget.authService)),
          ),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.tooltip, required this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      icon: Icon(icon, size: 20, color: Colors.white60),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 32),
    );
  }
}

/// Burbuja para reportar, con un resplandor que late suavemente.
class _ReportBubble extends StatelessWidget {
  const _ReportBubble({required this.pulse, required this.onTap});

  final Animation<double> pulse;
  final VoidCallback onTap;

  static const _neon = Color(0xFF39FF14);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 78,
        child: Column(
          children: [
            AnimatedBuilder(
              animation: pulse,
              builder: (_, child) => Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _CitizenReporterStripState._ringGradient,
                  boxShadow: [
                    BoxShadow(
                      color: _neon.withValues(alpha: 0.12 + 0.28 * pulse.value),
                      blurRadius: 8 + 12 * pulse.value,
                      spreadRadius: 1 + 2 * pulse.value,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2.5),
                child: child,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF101010),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.photo_camera_outlined, color: Colors.white, size: 26),
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _neon,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF101010), width: 2),
                        ),
                        child: const Icon(Icons.add, size: 14, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Reportar',
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// Noticia ciudadana aprobada, con anillo degradado.
class _StoryBubble extends StatelessWidget {
  const _StoryBubble({required this.report, required this.onTap});

  final Report report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 78,
        margin: const EdgeInsets.only(left: 6),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              padding: const EdgeInsets.all(2.5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: _CitizenReporterStripState._ringGradient,
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF101010),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: report.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => const ColoredBox(color: Colors.white10),
                    errorWidget: (_, _, _) => const ColoredBox(
                      color: Colors.white10,
                      child: Icon(Icons.image_not_supported_outlined,
                          color: Colors.white38, size: 22),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              report.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBubble extends StatelessWidget {
  const _SkeletonBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      margin: const EdgeInsets.only(left: 6),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
          ),
          const SizedBox(height: 6),
          Container(
            width: 44,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}