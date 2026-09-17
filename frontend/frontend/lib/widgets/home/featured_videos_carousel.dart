import 'package:flutter/material.dart';
import '../common/glass_container.dart';
import '../../models/content.dart';
import '../../services/auth_service.dart';
import '../../services/content_services.dart';
import '../../pages/video_player_screen.dart';
import '../../pages/youtube_player_screen.dart';

/// Sección "Videos destacados": título + carrusel horizontal.
/// Carga los videos con más vistas desde el backend.
class FeaturedVideosCarousel extends StatefulWidget {
  const FeaturedVideosCarousel({
    super.key,
    required this.authService,
    this.itemCount = 6,
  });

  final AuthService authService;
  final int itemCount;

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
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: _cargando
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF39FF14)),
                )
              : _videos.isEmpty
              ? const Center(
                  child: Text(
                    'Aún no hay videos destacados',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _videos.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _VideoCard(
                      content: _videos[index],
                      onTap: () => _abrirVideo(_videos[index]),
                    ),
                  ),
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
        width: 140,
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
                  errorBuilder: (_, __, ___) => const SizedBox(),
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
                  color: Colors.white,
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
