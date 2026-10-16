import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import '../../models/ad.dart';

/// Contenido del popup: video, imagen, o un mensaje si no hay nada que mostrar.
class AdPopupContent extends StatelessWidget {
  const AdPopupContent({
    super.key,
    required this.ad,
    required this.videoController,
    this.accentColor = const Color(0xFF39FF14),
  });

  final AdItem ad;
  final VideoPlayerController? videoController;
  final Color accentColor;

  Widget _loading() {
    return SizedBox(
      height: 220,
      child: Center(child: CircularProgressIndicator(color: accentColor)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (ad.type == 'video') {
      final video = videoController;
      if (video == null || !video.value.isInitialized) return _loading();
      return AspectRatio(
        aspectRatio: video.value.aspectRatio,
        child: VideoPlayer(video),
      );
    }

    // banner o popup: imagen
    if (ad.mediaUrl.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'Anuncio sin imagen',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return Image.network(
      ad.mediaUrl,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        return progress == null ? child : _loading();
      },
      errorBuilder: (_, error, _) {
        debugPrint('AD IMAGE ERROR -> url: ${ad.mediaUrl}');
        debugPrint('AD IMAGE ERROR -> $error');
        return const SizedBox(
          height: 160,
          child: Center(
            child: Icon(Icons.broken_image, color: Colors.white38, size: 40),
          ),
        );
      },
    );
  }
}