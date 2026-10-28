import 'package:flutter/material.dart';
import '../common/glass_container.dart';
import '../../models/content.dart';
import '../../services/auth_service.dart';
import '../../services/content_services.dart';
import '../../services/report_service.dart';
import '../../pages/report_detail_screen.dart';
import '../../pages/video_player_screen.dart';
import '../../pages/youtube_player_screen.dart';

/// Sección "Destacados": título + cuadrícula en bloque.
/// Muestra primero las últimas noticias ciudadanas aprobadas (hasta
/// [maxReports]) y completa con los videos con más vistas.
class FeaturedVideosCarousel extends StatefulWidget {
  const FeaturedVideosCarousel({
    super.key,
    required this.authService,
    this.itemCount = 6,
    this.columnas = 2,
    this.maxReports = 2,
  });

  final AuthService authService;
  final int itemCount;

  /// Número de columnas de la cuadrícula.
  final int columnas;

  /// Máximo de noticias ciudadanas que se mezclan arriba de los videos.
  final int maxReports;

  @override
  State<FeaturedVideosCarousel> createState() => _FeaturedVideosCarouselState();
}

class _FeaturedVideosCarouselState extends State<FeaturedVideosCarousel> {
  late final ContentService _contentService;
  late final ReportService _reportService;
  bool _cargando = true;
  List<ContentItem> _videos = [];

  @override
  void initState() {
    super.initState();
    _contentService = ContentService(authService: widget.authService);
    _reportService = ReportService(widget.authService);
    _cargar();
  }

  Future<void> _cargar() async {
    final results = await Future.wait<List<ContentItem>>([
      _contentService.obtenerVideosDestacados(limit: widget.itemCount),
      // Si las noticias ciudadanas fallan, los videos siguen saliendo normal.
      _reportService
          .getFeaturedNews(limit: widget.maxReports)
          .catchError((_) => <ContentItem>[]),
    ]);

    final ids = <String>{};
    final merged = <ContentItem>[];
    for (final c in results[1]) {
      if (merged.length < widget.itemCount && ids.add(c.id)) merged.add(c);
    }
    for (final c in results[0]) {
      if (merged.length >= widget.itemCount) break;
      if (ids.add(c.id)) merged.add(c);
    }

    if (!mounted) return;
    setState(() {
      _videos = merged;
      _cargando = false;
    });
  }

  Future<void> _abrirVideo(ContentItem content) async {
    if (content.isCitizenReport) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReportDetailScreen(
            report: content.toReport(),
            authService: widget.authService,
          ),
        ),
      );
    } else if (content.isYoutube) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => YoutubePlayerScreen(
            content: content,
            authService: widget.authService,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(
            content: content,
            authService: widget.authService,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Destacados',
          style: TextStyle(
            color: Color.fromARGB(255, 248, 245, 245),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_cargando)
          const SizedBox(
            height: 120,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF39FF14)),
            ),
          )
        else if (_videos.isEmpty)
          const SizedBox(
            height: 120,
            child: Center(
              child: Text(
                'Aún no hay contenido destacado',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _videos.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.columnas,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 16 / 10,
            ),
            itemBuilder: (context, index) => _VideoCard(
              content: _videos[index],
              onTap: () => _abrirVideo(_videos[index]),
            ),
          ),
      ],
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.content, required this.onTap});

  final ContentItem content;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final citizen = content.isCitizenReport;

    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        blurSigma: 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (content.thumbnailUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  content.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox(),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Text(
                content.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color.fromARGB(255, 170, 165, 165),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            if (citizen)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF39FF14), width: 1),
                  ),
                  child: const Text(
                    'CIUDADANO',
                    style: TextStyle(
                      color: Color(0xFF39FF14),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              )
            else
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 22,
                ),
              ),
          ],
        ),
      ),
    );
  }
}