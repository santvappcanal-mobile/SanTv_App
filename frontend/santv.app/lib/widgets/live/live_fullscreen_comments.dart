import 'package:flutter/material.dart';
import 'package:santv_app/services/live_comment_service.dart';
import 'package:santv_app/widgets/live/live_comments_panel.dart';

/// Posiciona los comentarios del en vivo ampliado:
/// - Horizontal: overlay a la izquierda, encima del video (estilo Facebook Live).
/// - Vertical: panel completo debajo del video.
class LiveFullscreenComments extends StatelessWidget {
  const LiveFullscreenComments({
    super.key,
    required this.service,
    required this.landscape,
    required this.videoHeight,
  });

  final LiveCommentService service;
  final bool landscape;
  final double videoHeight;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final keyboard = media.viewInsets.bottom;

    if (landscape) {
      return Positioned(
        left: 12 + media.padding.left,
        bottom: keyboard + 8,
        width: size.width * 0.42,
        height: size.height * 0.6,
        child: LiveCommentsPanel(service: service, overlay: true),
      );
    }

    return Positioned(
      left: 0,
      right: 0,
      top: videoHeight,
      bottom: keyboard,
      child: LiveCommentsPanel(service: service),
    );
  }
}