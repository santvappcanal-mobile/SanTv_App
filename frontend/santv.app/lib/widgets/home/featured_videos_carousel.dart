import 'package:flutter/material.dart';
import '../common/glass_container.dart';
import '../../models/content.dart';
import '../../services/auth_service.dart';
import '../../services/content_services.dart';
import '../../pages/video_player_screen.dart';
import '../../pages/youtube_player_screen.dart';

/// Sección "Videos destacados": título + cuadrícula en bloque.
/// Carga los videos con más vistas desde el backend.
class FeaturedVideosCarousel extends StatefulWidget {
  const FeaturedVideosCarousel({
    super.key,
    required this.authService,
    this.itemCount = 6,
    this.columnas = 2,
  });

  final AuthService authService;
  final int itemCount;

  /// Número de columnas de la cuadrícula.
  final int columnas;

  @override
  State<FeaturedVideosCarousel> createState() => _FeaturedVideosCarouselState();
}

class _FeaturedVideosCarouselState extends State<FeaturedVideosCarousel> {
  late final ContentService _contentService;
  bool _cargando = true;
  List<ContentItem> _videos = [];

  @override
  void initState() {
    super.initState();
    _contentService = ContentService(authService: widget.authService);
    _cargar();
  }

  Future<void> _cargar() async {
    final videos = await _contentService.obtenerVideosDestacados(
      limit: widget.itemCount,
    );
    if (!mounted) return;
    setState(() {
      _videos = videos;
      _cargando = false;
    });
  }

  Future<void> _abrirVideo(ContentItem content) async {
    if (content.isYoutube) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => YoutubePlayerScreen(content: content),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VideoPlayerScreen(content: content)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Videos destacados',
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
                'Aún no hay videos destacados',
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
