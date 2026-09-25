import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Encabezado del live: transmisión en vivo embebida, degradado, badge
/// "TRANSMISIÓN EN VIVO" y botón de silencio, todo en vidrio.
class LiveCoverHeader extends StatefulWidget {
  const LiveCoverHeader({
    super.key,
    required this.coverImageUrl,
    required this.muted,
    required this.onToggleMute,
  });

  final String coverImageUrl;
  final bool muted;
  final VoidCallback onToggleMute;

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
          onPageFinished: (_) => setState(() => _loading = false),
        ),
      )
      ..loadRequest(Uri.parse(_liveUrl));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
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
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
          ),
          const Positioned(
            top: 12,
            left: 12,
            child: _LiveBadge(neonGreen: LiveCoverHeader.neonGreen),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: _MuteButton(muted: widget.muted, onTap: widget.onToggleMute),
          ),
        ],
      ),
    );
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