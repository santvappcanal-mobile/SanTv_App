import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:santv_app/services/auth_service.dart';
import 'package:santv_app/services/live_comment_service.dart';
import 'package:santv_app/widgets/live/live_comments_panel.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// En vivo ampliado.
/// - Vertical: video 16:9 arriba (sin deformarse) y comentarios abajo.
/// - Horizontal: video a pantalla completa y comentarios encima, estilo
///   Facebook Live.
/// Gira solo con el teléfono; al salir vuelve a vertical.
class LiveFullscreenScreen extends StatefulWidget {
  const LiveFullscreenScreen({
    super.key,
    required this.streamUrl,
    this.authService,
  });

  final String streamUrl;

  /// Si es null no se muestran comentarios (solo el video).
  final AuthService? authService;

  @override
  State<LiveFullscreenScreen> createState() => _LiveFullscreenScreenState();
}

class _LiveFullscreenScreenState extends State<LiveFullscreenScreen> {
  static const Duration _retryEvery = Duration(milliseconds: 1500);
  static const int _maxAttempts = 14;

  // Evita que el reproductor web abra su propio pantalla completa nativo
  // (el que se veía estirado) y fuerza al video a ajustarse sin recortar.
  static const String _fitJs = '''
    (function () {
      function noop() { return Promise.resolve(); }
      Element.prototype.requestFullscreen = noop;
      Element.prototype.webkitRequestFullscreen = noop;
      Element.prototype.webkitRequestFullScreen = noop;
      HTMLVideoElement.prototype.webkitEnterFullscreen = noop;
      HTMLVideoElement.prototype.webkitEnterFullScreen = noop;

      document.documentElement.style.background = '#000';
      document.body.style.background = '#000';
      document.body.style.margin = '0';
      document.body.style.overflow = 'hidden';

      document.querySelectorAll('video').forEach(function (v) {
        v.style.objectFit = 'contain';
        v.style.background = '#000';
        v.setAttribute('playsinline', '');
        if (v.paused) {
          v.muted = false;
          var p = v.play();
          if (p && p.catch) { p.catch(function () { v.muted = true; v.play(); }); }
        }
      });
    })();
  ''';

  late final WebViewController _web;
  final GlobalKey _webKey = GlobalKey();
  Timer? _timer;
  bool _loading = true;
  LiveCommentService? _comments;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    final auth = widget.authService;
    if (auth != null) {
      _comments = LiveCommentService(baseUrl: auth.baseUrl)..connect();
    }

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _web = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _loading = false);
            _startRetries();
          },
        ),
      );

    final platform = _web.platform;
    if (platform is AndroidWebViewController) {
      platform.setMediaPlaybackRequiresUserGesture(false);
    }

    _web.loadRequest(Uri.parse(widget.streamUrl));
  }

  /// El <video> puede aparecer tarde, por eso se reintenta un rato.
  void _startRetries() {
    _timer?.cancel();
    var attempts = 0;
    _web.runJavaScript(_fitJs);
    _timer = Timer.periodic(_retryEvery, (t) {
      attempts++;
      if (!mounted || attempts >= _maxAttempts) {
        t.cancel();
        return;
      }
      _web.runJavaScript(_fitJs);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _web.runJavaScript(
      "document.querySelectorAll('video').forEach(function(v){ v.pause(); });",
    );
    _comments?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final pad = media.padding;
    final keyboard = media.viewInsets.bottom;
    final landscape = size.width > size.height;
    final comments = _comments;

    // Mismos widgets en ambas orientaciones (solo cambia su posición),
    // así el WebView no se recarga al girar el teléfono.
    final double videoHeight = landscape ? size.height : size.width * 9 / 16;

    final video = Positioned(
      left: 0,
      right: 0,
      top: 0,
      height: videoHeight,
      child: ColoredBox(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            WebViewWidget(key: _webKey, controller: _web),
            if (_loading)
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

    Widget? panel;
    if (comments != null) {
      panel = landscape
          ? Positioned(
              left: 12 + pad.left,
              bottom: keyboard + 8,
              width: size.width * 0.42,
              height: size.height * 0.6,
              child: LiveCommentsPanel(service: comments, overlay: true),
            )
          : Positioned(
              left: 0,
              right: 0,
              top: videoHeight,
              bottom: keyboard,
              child: LiveCommentsPanel(service: comments),
            );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          video,
          if (panel != null) panel,
          Positioned(
            top: 8 + pad.top,
            right: 8 + pad.right,
            child: _RoundButton(
              icon: Icons.fullscreen_exit_rounded,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}