import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../models/ad.dart';
import '../../services/ad_service.dart';
import 'ad_popup_close_button.dart';
import 'ad_popup_content.dart';

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
    // Los PDF legales no se muestran en el modal ni cuentan vistas.
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
                child: AdPopupContent(
                  ad: widget.ad,
                  videoController: _videoController,
                ),
              ),
            ),
          ),
          Positioned(
            top: -14,
            right: -14,
            child: AdPopupCloseButton(onTap: () => Navigator.of(context).pop()),
          ),
        ],
      ),
    );
  }
}