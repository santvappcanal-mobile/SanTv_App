import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Reproductor del live: transmisión en vivo embebida, badge
/// "TRANSMISIÓN EN VIVO" y botón de silencio, todo en vidrio.
///
/// Si [height] es null, ocupa todo el espacio disponible (pantalla completa).
class LiveCoverHeader extends StatefulWidget {
  const LiveCoverHeader({
    super.key,
    required this.coverImageUrl,
    required this.muted,
    required this.onToggleMute,
    this.height,
    this.badgeLeft = 12,
  });

  final String coverImageUrl;
  final bool muted;
  final VoidCallback onToggleMute;

  /// Alto fijo opcional. Null = se expande al máximo.
  final double? height;

  /// Distancia del badge al borde izquierdo (para dejar lugar a la flecha).
  final double badgeLeft;

  static const Color neonGreen = Color(0xFF39FF14);

  @override
  State<LiveCoverHeader> createState() => _LiveCoverHeaderState();
}

class _LiveCoverHeaderState extends State<LiveCoverHeader> {
  static const String _liveUrl = 'https://streaminghd.co/user/produccionessantv';

  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(_liveUrl));
  }

  @override
  Widget build(BuildContext context) {
    final stack = Stack(
      children: [
        Positioned.fill(
          child: _loading
              ? Image.network(widget.coverImageUrl, fit: BoxFit.cover)
              : WebViewWidget(controller: _controller),
        ),
        if (_loading)
          const Positioned.fill(
            child: Center(
              child: CircularProgressIndicator(color: LiveCoverHeader.neonGreen),
            ),
          ),
        // Degradado solo cuando el reproductor tiene alto fijo;
        // IgnorePointer para que no bloquee los toques al video.
        if (widget.height != null)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          top: 12,
          left: widget.badgeLeft,
          child: const _LiveBadge(neonGreen: LiveCoverHeader.neonGreen),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: _MuteButton(muted: widget.muted, onTap: widget.onToggleMute),
        ),
      ],
    );

    if (widget.height != null) {
      return SizedBox(height: widget.height, child: stack);
    }
    return SizedBox.expand(child: stack);
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.neonGreen});
  final Color neonGreen;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: neonGreen.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.circle, color: Colors.red, size: 10),
              const SizedBox(width: 6),
              Text(
                'TRANSMISIÓN EN VIVO',
                style: TextStyle(
                  color: neonGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MuteButton extends StatelessWidget {
  const _MuteButton({required this.muted, required this.onTap});
  final bool muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: IconButton(
            icon: Icon(
              muted ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
            ),
            onPressed: onTap,
          ),
        ),
      ),
    );
  }
}