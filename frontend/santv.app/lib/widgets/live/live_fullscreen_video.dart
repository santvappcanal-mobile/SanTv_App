import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Video del en vivo ampliado: WebView pegado arriba con loader.
/// Mismo widget en vertical y horizontal (solo cambia [height]); el
/// [webKey] evita que el WebView se recargue al girar el teléfono.
class LiveFullscreenVideo extends StatelessWidget {
  const LiveFullscreenVideo({
    super.key,
    required this.controller,
    required this.webKey,
    required this.loading,
    required this.height,
  });

  final WebViewController controller;
  final GlobalKey webKey;
  final bool loading;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      height: height,
      child: ColoredBox(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            WebViewWidget(key: webKey, controller: controller),
            if (loading)
              const ColoredBox(
                color: Colors.black,
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF39FF14)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}