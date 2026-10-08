import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../models/ad.dart';
import '../../services/ad_service.dart';

/// Muestra el contenido de [AdPopupDialog.showAd] como un modal centrado,
/// con botón de cerrar. Registra la impresión al mostrarse, y el clic
/// si el usuario toca el contenido y hay un targetUrl.
class AdPopupDialog extends StatefulWidget {
  const AdPopupDialog({super.key, required this.ad, required this.adService});

  final AdItem ad;
  final AdService adService;

  static Future<void> showAd(
    BuildContext context, {
    required AdItem ad,
    required AdService adService,
  }) {
    // NUEVO: los PDF legales no se muestran en el modal ni cuentan vistas.
    if (ad.type == 'document') return Future.value();

    adService.registrarImpresion(ad.id);
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AdPopupDialog(ad: ad, adService: adService),
    );
  }

  @override
  State<AdPopupDialog> createState() => _AdPopupDialogState();
}

class _AdPopupDialogState extends State<AdPopupDialog> {
  VideoPlayerController? _videoController;

  static const Color _neonGreen = Color(0xFF39FF14);

  @override
  void initState() {
    super.initState();
    if (widget.ad.type == 'video' && widget.ad.mediaUrl.isNotEmpty) {
      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(widget.ad.mediaUrl))
            ..initialize().then((_) {
              if (mounted) setState(() {});
              _videoController?.play();
            });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await widget.adService.registrarClic(widget.ad.id);
    final target = widget.ad.targetUrl;
    if (target == null || target.isEmpty) return;

    final uri = Uri.tryParse(target);
    if (uri == null) return;

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GestureDetector(
              onTap: _handleTap,
              child: Container(
                color: const Color(0xFF1A1A1A),
                constraints: const BoxConstraints(maxHeight: 420),
                child: _buildContent(),
              ),
            ),
          ),
          Positioned(
            top: -14,
            right: -14,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: _neonGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.black, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (widget.ad.type == 'video') {
      if (_videoController == null || !_videoController!.value.isInitialized) {
        return const SizedBox(
          height: 220,
          child: Center(child: CircularProgressIndicator(color: _neonGreen)),
        );
      }
      return AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      );
    }

    // banner o popup: imagen
    if (widget.ad.mediaUrl.isEmpty) {
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
      widget.ad.mediaUrl,
      fit: BoxFit.contain,
      // NUEVO: muestra un cargando mientras baja la imagen
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const SizedBox(
          height: 220,
          child: Center(child: CircularProgressIndicator(color: _neonGreen)),
        );
      },
      // NUEVO: imprime la causa del error en la consola de Flutter
      errorBuilder: (_, error, __) {
        debugPrint('AD IMAGE ERROR -> url: ${widget.ad.mediaUrl}');
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
