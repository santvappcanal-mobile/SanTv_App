import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Reproduce un video de Referencias (URL de Cloudinary).
class ReferenceVideoPlayerPage extends StatefulWidget {
  const ReferenceVideoPlayerPage({
    super.key,
    required this.url,
    required this.titulo,
  });

  final String url;
  final String titulo;

  @override
  State<ReferenceVideoPlayerPage> createState() =>
      _ReferenceVideoPlayerPageState();
}

class _ReferenceVideoPlayerPageState extends State<ReferenceVideoPlayerPage> {
  static const Color neonGreen = Color(0xFF39FF14);

  late final VideoPlayerController _controller;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _controller
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() {});
          _controller.play();
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
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.titulo,
          style: const TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Center(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_error) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No se pudo reproducir el video',
          style: TextStyle(color: Colors.white54),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (!_controller.value.isInitialized) {
      return const CircularProgressIndicator(color: neonGreen);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: GestureDetector(
            onTap: _togglePlay,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller),
                if (!_controller.value.isPlaying)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: neonGreen,
                      size: 48,
                    ),
                  ),
              ],
            ),
          ),
        ),
        VideoProgressIndicator(
          _controller,
          allowScrubbing: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          colors: const VideoProgressColors(
            playedColor: neonGreen,
            bufferedColor: Colors.white24,
            backgroundColor: Colors.white12,
          ),
        ),
      ],
    );
  }
}