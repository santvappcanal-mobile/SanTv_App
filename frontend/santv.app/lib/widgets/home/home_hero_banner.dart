import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../common/glass_container.dart';

/// Banner superior de la pestaña de inicio ("Canal en vivo").
/// Ahora reproduce el stream real en vivo (autoplay).
class HomeHeroBanner extends StatefulWidget {
  const HomeHeroBanner({super.key, required this.neonColor});

  final Color neonColor;

  @override
  State<HomeHeroBanner> createState() => _HomeHeroBannerState();
}

class _HomeHeroBannerState extends State<HomeHeroBanner> {
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
    return GlassContainer(
      height: 200,
      width: double.infinity,
      gradientColors: [
        widget.neonColor.withValues(alpha: 0.20),
        Colors.white.withValues(alpha: 0.05),
      ],
      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      boxShadow: [
        BoxShadow(
          color: widget.neonColor.withValues(alpha: 0.15),
          blurRadius: 30,
          spreadRadius: -8,
        ),
      ],
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16), // ajusta si tu GlassContainer usa otro radio
        child: Stack(
          fit: StackFit.expand,
          children: [
            WebViewWidget(controller: _controller),
            if (_loading)
              Container(
                color: Colors.black87,
                child: Center(
                  child: CircularProgressIndicator(color: widget.neonColor),
                ),
              ),
            const Positioned(top: 10, left: 10, child: _LiveBadgeSmall()),
          ],
        ),
      ),
    );
  }
}

class _LiveBadgeSmall extends StatelessWidget {
  const _LiveBadgeSmall();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: Colors.red, size: 8),
          SizedBox(width: 4),
          Text(
            'EN VIVO',
            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}