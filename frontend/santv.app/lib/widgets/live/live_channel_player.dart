import 'dart:async';

import 'package:flutter/material.dart';
import 'package:santv_app/widgets/live_tab/pulsing_live_dot.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// Reproductor del canal en vivo de SAN TV (WebView con autoplay).
/// Se usa en el Home y en la pestaña En vivo. Ambos cargan el mismo
/// directo, así que siempre están sincronizados.
///
/// [isActive] controla si debe sonar: solo el reproductor visible
/// reproduce, el otro se mantiene pausado.
/// [onTap], si se pasa, intercepta el toque sobre el video (ej. en el
/// Home para llevar a la pestaña En vivo).
class LiveChannelPlayer extends StatefulWidget {
  const LiveChannelPlayer({
    super.key,
    required this.isActive,
    this.onTap,
    this.showLiveBadge = true,
  });

  final bool isActive;
  final VoidCallback? onTap;
  final bool showLiveBadge;

  @override
  State<LiveChannelPlayer> createState() => _LiveChannelPlayerState();
}

class _LiveChannelPlayerState extends State<LiveChannelPlayer> {
  static const String _liveUrl =
      'https://streaminghd.co/user/produccionessantv';

  /// Los reproductores web crean el <video> unos segundos después de
  /// cargar la página, por eso se reintenta varias veces.
  static const Duration _retryEvery = Duration(milliseconds: 1500);
  static const int _maxAttempts = 14;

  /// Si estuvo pausado más de esto, se recarga la página al reactivarlo
  /// para volver al punto actual del directo.
  static const Duration _reloadAfterPause = Duration(seconds: 10);

  static const String _playJs = '''
    (function () {
      var videos = document.querySelectorAll('video');
      videos.forEach(function (v) {
        v.setAttribute('playsinline', '');
        if (v.paused) {
          v.muted = false;
          var p = v.play();
          if (p && p.catch) {
            p.catch(function () { v.muted = true; v.play(); });
          }
        }
      });

      var playing = Array.prototype.some.call(videos, function (v) {
        return !v.paused;
      });
      if (!playing) {
        [
          '.vjs-big-play-button',
          '.jw-icon-display',
          '.plyr__control--overlaid',
          '.ytp-large-play-button',
          '.mejs__overlay-button',
          '[aria-label="Play"]',
          '[aria-label="Reproducir"]',
          '.play-button',
          '.btn-play',
          '#play'
        ].forEach(function (s) {
          var el = document.querySelector(s);
          if (el) el.click();
        });
      }
    })();
  ''';

  static const String _pauseJs =
      "document.querySelectorAll('video').forEach(function(v){ v.pause(); });";

  late final WebViewController _controller;
  Timer? _timer;
  bool _loading = true;
  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    _pausedAt = widget.isActive ? null : DateTime.now();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _loading = false);
            _applyState();
          },
        ),
      );

    final platform = _controller.platform;
    if (platform is AndroidWebViewController) {
      platform.setMediaPlaybackRequiresUserGesture(false);
    }

    _controller.loadRequest(Uri.parse(_liveUrl));
  }

  /// Aplica el estado actual: da play si está activo, pausa si no.
  /// Reintenta un rato porque el <video> puede aparecer tarde.
  void _applyState() {
    _timer?.cancel();
    var attempts = 0;

    _controller.runJavaScript(widget.isActive ? _playJs : _pauseJs);

    _timer = Timer.periodic(_retryEvery, (timer) {
      attempts++;
      if (!mounted || attempts >= _maxAttempts) {
        timer.cancel();
        return;
      }
      _controller.runJavaScript(widget.isActive ? _playJs : _pauseJs);
    });
  }

  @override
  void didUpdateWidget(covariant LiveChannelPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive == widget.isActive) return;

    if (widget.isActive) {
      final pausedAt = _pausedAt;
      _pausedAt = null;
      final pausedLong = pausedAt != null &&
          DateTime.now().difference(pausedAt) > _reloadAfterPause;
      if (pausedLong) {
        // Recarga para volver al directo; onPageFinished da el play.
        setState(() => _loading = true);
        _controller.reload();
      } else {
        _applyState();
      }
    } else {
      _pausedAt = DateTime.now();
      _applyState(); // pausa
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final neonColor = Theme.of(context).colorScheme.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            WebViewWidget(controller: _controller),
            if (_loading)
              Container(
                color: Colors.black87,
                child: Center(
                  child: CircularProgressIndicator(color: neonColor),
                ),
              ),
            if (widget.onTap != null)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onTap,
                ),
              ),
            if (widget.showLiveBadge)
              Positioned(
                top: 10,
                left: 10,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PulsingLiveDot(),
                        SizedBox(width: 6),
                        Text(
                          'EN VIVO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
