import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/content.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import '../services/watchlist_service.dart';
import '../widgets/common/comments_section.dart';
import '../widgets/common/save_to_list_button.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({
    super.key,
    required this.content,
    required this.authService,
    this.watchlistService,
    this.initialSaved = false,
  });

  final ContentItem content;

  /// Se usa para cargar y publicar los comentarios del video.
  final AuthService authService;

  /// Si se pasa, se muestra el botón de guardar en Mi Lista en la barra superior.
  final WatchlistService? watchlistService;
  final bool initialSaved;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  static const Color _neon = Color(0xFF39FF14);

  late VideoPlayerController _controller;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.content.videoUrl))
          ..initialize()
              .then((_) async {
                final autoplay = await SettingsService.getAutoplay();
                if (!mounted) return;
                setState(() {});
                if (autoplay) _controller.play();
              })
              .catchError((_) {
                if (!mounted) return;
                setState(() => _error = true);
              });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    _controller.value.isPlaying ? _controller.pause() : _controller.play();
  }

  /// El video con su botón de play/pausa encima (tocar el video también
  /// pausa o reanuda). Reemplaza al botón flotante de antes, que taparía
  /// el campo de comentarios.
  Widget _videoContent() {
    if (_error) {
      return const Center(
        child: Text(
          'No se pudo reproducir el video.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: _neon));
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          children: [
            VideoPlayer(_controller),
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _togglePlay,
                child: ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: _controller,
                  builder: (context, value, child) => Center(
                    child: AnimatedOpacity(
                      opacity: value.isPlaying ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.55),
                          border: Border.all(color: _neon, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: _neon,
                          size: 34,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: _neon,
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.white12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // En horizontal solo se ve el video; los comentarios quedan para vertical.
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.content.title,
          style: const TextStyle(color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (widget.watchlistService != null)
            SaveToListButton(
              contentId: widget.content.id,
              watchlistService: widget.watchlistService!,
              initialSaved: widget.initialSaved,
            ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B0B0B), Color(0xFF10241A), Color(0xFF0B0B0B)],
          ),
        ),
        child: landscape
            ? _videoContent()
            : SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        color: Colors.black,
                        child: _videoContent(),
                      ),
                    ),
                    Expanded(
                      child: CommentsSection(
                        contentId: widget.content.id,
                        authService: widget.authService,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}