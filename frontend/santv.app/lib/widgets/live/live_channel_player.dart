import 'package:flutter/material.dart';
import 'package:santv_app/pages/live_fullscreen_screen.dart';
import 'package:santv_app/services/auth_service.dart';
import 'package:santv_app/widgets/live/live_badge.dart';
import 'package:santv_app/widgets/live/live_script_runner.dart';
import 'package:santv_app/widgets/live/live_web_controller.dart';
import 'package:santv_app/widgets/live/live_web_scripts.dart';
import 'package:santv_app/widgets/live/round_icon_button.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Reproductor del canal en vivo de SAN TV (WebView con autoplay).
/// Se usa en el Home y en la pestaña En vivo. Ambos cargan el mismo
/// directo, así que siempre están sincronizados.
///
/// [isActive] controla si debe sonar: solo el reproductor visible
/// reproduce, el otro se mantiene pausado.
/// [onTap], si se pasa, intercepta el toque sobre el video (ej. en el
/// Home para llevar a la pestaña En vivo).
/// [authService], si se pasa, habilita los comentarios en vivo al
/// ampliar el video.
class LiveChannelPlayer extends StatefulWidget {
  const LiveChannelPlayer({
    super.key,
    required this.isActive,
    this.onTap,
    this.showLiveBadge = true,
    this.authService,
  });

  final bool isActive;
  final VoidCallback? onTap;
  final bool showLiveBadge;
  final AuthService? authService;

  @override
  State<LiveChannelPlayer> createState() => _LiveChannelPlayerState();
}

class _LiveChannelPlayerState extends State<LiveChannelPlayer> {
  static const String _liveUrl =
      'https://streaminghd.co/user/produccionessantv';

  /// Si estuvo pausado más de esto, se recarga la página al reactivarlo
  /// para volver al punto actual del directo.
  static const Duration _reloadAfterPause = Duration(seconds: 10);

  late final WebViewController _controller;
  late final LiveScriptRunner _scripts;
  bool _loading = true;
  bool _fullscreenOpen = false;
  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    _pausedAt = widget.isActive ? null : DateTime.now();

    _controller = createLiveWebController()
      ..addJavaScriptChannel(
        'SanTvBridge',
        onMessageReceived: (message) {
          if (message.message == 'fullscreen' &&
              widget.isActive &&
              widget.onTap == null) {
            _openFullscreen();
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) =>
              _controller.runJavaScript(LiveWebScripts.fullscreenBridge),
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _loading = false);
            _controller.runJavaScript(LiveWebScripts.fullscreenBridge);
            _applyState();
          },
        ),
      )
      ..loadRequest(Uri.parse(_liveUrl));

    _scripts = LiveScriptRunner(_controller);
  }

  /// Abre el en vivo ampliado (con comentarios y rotación). Mientras
  /// está abierto, este reproductor se pausa para que no suene doble.
  Future<void> _openFullscreen() async {
    if (_fullscreenOpen || !mounted) return;
    _fullscreenOpen = true;

    _scripts.cancel();
    _controller.runJavaScript(LiveWebScripts.pause);

    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => LiveFullscreenScreen(
          streamUrl: _liveUrl,
          authService: widget.authService,
        ),
      ),
    );

    _fullscreenOpen = false;
    if (!mounted) return;

    // Al volver se recarga para quedar en el punto actual del directo.
    setState(() => _loading = true);
    _controller.reload();
  }

  /// Aplica el estado actual: da play si está activo, pausa si no.
  /// Reintenta un rato porque el <video> puede aparecer tarde.
  void _applyState() {
    _scripts.run(
      () => [
        LiveWebScripts.hideFullscreenButton,
        widget.isActive ? LiveWebScripts.play : LiveWebScripts.pause,
      ],
      isAlive: () => mounted,
    );
  }

  @override
  void didUpdateWidget(covariant LiveChannelPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive == widget.isActive) return;
    if (_fullscreenOpen) return; // el ampliado manda sobre el estado

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
    _scripts.cancel();
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
              const Positioned(
                top: 10,
                left: 10,
                child: IgnorePointer(child: LiveBadge()),
              ),
            // Botón propio de ampliar (por si el del reproductor web no
            // avisa a Flutter). Solo en la pestaña En vivo, no en el Home.
            if (widget.onTap == null)
              Positioned(
                top: 10,
                right: 10,
                child: RoundIconButton(
                  icon: Icons.fullscreen_rounded,
                  onTap: _openFullscreen,
                  size: 34,
                  alpha: 0.6,
                ),
              ),
          ],
        ),
      ),
    );
  }
}