import 'package:flutter/material.dart';

import '../models/chat_reply.dart';
import '../models/content.dart';
import '../pages/pdf_viewer_page.dart';
import '../pages/reference_video_player_page.dart';
import '../pages/video_player_screen.dart';
import '../pages/youtube_player_screen.dart';
import '../services/auth_service.dart';
import '../models/gallery_item.dart';
import 'common/gallery_grid.dart';

/// Tarjeta tocable que aparece debajo de un mensaje del asistente.
/// - 'video' y 'contenido': abren el reproductor normal de la app (Cloudinary o YouTube).
/// - 'portafolio': abre la imagen ampliada del portafolio.
/// - 'referencia': abre el reproductor de videos de Referencias.
/// - 'documento': abre el visor de PDF.
class ChatAttachmentCard extends StatelessWidget {
  const ChatAttachmentCard({
    super.key,
    required this.attachment,
    required this.authService,
  });

  final ChatAttachment attachment;
  final AuthService authService;

  static const Color neonGreen = Color(0xFF39FF14);

  bool get _esDocumento => attachment.tipo == 'documento';

  String get _etiqueta {
    switch (attachment.tipo) {
      case 'video':
        return 'Video más visto de la semana';
      case 'contenido':
        return 'Te puede interesar';
      case 'portafolio':
        return 'Portafolio SAN TV';
      case 'referencia':
        return 'Referencia de publicidad';
      case 'documento':
        return 'Documento de pauta';
      default:
        return '';
    }
  }

  bool _esYoutube(String url) =>
      url.contains('youtube.com') || url.contains('youtu.be');

  void _abrir(BuildContext context) {
    try {
      switch (attachment.tipo) {
        case 'video':
        case 'contenido':
          final data = attachment.contenido;
          if (data == null) return;
          final content = ContentItem.fromJson(data);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _esYoutube(attachment.url)
                  ? YoutubePlayerScreen(
                      content: content,
                      authService: authService,
                    )
                  : VideoPlayerScreen(
                      content: content,
                      authService: authService,
                    ),
            ),
          );
          break;

        case 'referencia':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReferenceVideoPlayerPage(
                url: attachment.url,
                titulo: attachment.titulo,
              ),
            ),
          );
          break;

        case 'portafolio':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GalleryViewerPage(
                items: [
                  GalleryItem(
                    id: '',
                    title: attachment.titulo,
                    mediaUrl: attachment.url,
                    description: attachment.descripcion,
                  ),
                ],
                initialIndex: 0,
              ),
            ),
          );
          break;

        case 'documento':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PdfViewerPage(
                url: attachment.url,
                titulo: attachment.titulo,
              ),
            ),
          );
          break;
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el contenido')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _esDocumento ? _buildDocumento(context) : _buildVideo(context);
  }

  // ─────────────── Tarjeta de documento (PDF) ───────────────
  Widget _buildDocumento(BuildContext context) {
    return InkWell(
      onTap: () => _abrir(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: neonGreen.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: neonGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.picture_as_pdf_rounded, color: neonGreen),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _etiqueta,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    attachment.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: neonGreen,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────── Tarjeta de video (más visto / referencia) ───────────────
  Widget _buildVideo(BuildContext context) {
    return GestureDetector(
      onTap: () => _abrir(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 150,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Miniatura con respaldo si no hay o falla
              if (attachment.miniatura.isNotEmpty)
                Image.network(
                  attachment.miniatura,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fondoSinMiniatura(),
                )
              else
                _fondoSinMiniatura(),
              // Degradado para que se lea el texto
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
              // Botón de play (las imágenes del portafolio no lo llevan)
              if (attachment.tipo != 'portafolio')
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: neonGreen, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: neonGreen,
                      size: 30,
                    ),
                  ),
                ),
              // Etiqueta + título (+ descripción si hay)
              Positioned(
                left: 12,
                right: 12,
                bottom: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _etiqueta,
                      style: const TextStyle(color: neonGreen, fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      attachment.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    if (attachment.descripcion.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        attachment.descripcion,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fondoSinMiniatura() {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: const Icon(
        Icons.videocam_rounded,
        color: Colors.white24,
        size: 48,
      ),
    );
  }
}