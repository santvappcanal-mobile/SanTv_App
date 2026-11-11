import 'dart:async';

import 'package:flutter/material.dart';
import 'package:santv_app/pages/live_fullscreen_screen.dart';
import 'package:santv_app/services/auth_service.dart';
import 'package:santv_app/services/playback_coordinator.dart';
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
///
/// Cuando se abre cualquier video (ver [PlaybackCoordinator]) el en vivo
/// se APAGA por completo (se descarga la página) y al cerrar el video se
/// vuelve a cargar solo. Pausar con JavaScript no alcanza si el
/// reproductor va dentro de un iframe, por eso se descarga la página.
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

  static const String _blankUrl = 'about:blank';

  /// Si estuvo pausado más de esto, se recarga la página al reactivarlo
  /// para volver al punto actual del directo.
  static const Duration _reloadAfterPause = Duration(seconds: 10);

  final PlaybackCoordinator _coordinator = PlaybackCoordinator.instance;

  late final WebViewController _controller;
  late final LiveScriptRunner _scripts;
  bool _loading = true;
  bool _fullscreenOpen = false;

  /// true cuando el en vivo está apagado (WebView en about:blank)
  /// porque hay un video abierto encima.
  bool _stopped = false;
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
          onPageStarted: (url) {
            if (_stopped || url.startsWith(_blankUrl)) return;
            _controller.runJavaScript(LiveWebScripts.fullscreenBridge);
          },
          onPageFinished: (url) {
            if (!mounted || _stopped || url.startsWith(_blankUrl)) return;
            setState(() => _loading = false);
            _controller.runJavaScript(LiveWebScripts.fullscreenBridge);
            _applyState();
          },
        ),
      )
      ..loadRequest(Uri.parse(_liveUrl));

    _scripts = LiveScriptRunner(_controller);

    _coordinator.addListener(_onCoordinatorChanged);
  }

  /// Se abrió o se cerró un video. Se difiere con un microtask porque
  /// el aviso llega desde initState/dispose de otra pantalla, es decir,
  /// en medio de la construcción del árbol de widgets.
  void _onCoordinatorChanged() {
    scheduleMicrotask(() {
      if (!mounted) return;
      if (_coordinator.hasVideoOpen) {
        _stopHard();
      } else if (widget.isActive && !_fullscreenOpen) {
        _resume();
      }
    });
  }

  /// Apaga el en vivo: pausa y descarga la página para que no suene nada.
  void _stopHard() {
    if (_stopped) return;
    _stopped = true;
    _pausedAt = DateTime.now();
    _scripts.cancel();
    _controller.runJavaScript(LiveWebScripts.pause);
    _controller.loadRequest(Uri.parse(_blankUrl));
  }

  /// Vuelve a cargar el directo si estaba apagado.
  void _resume() {
    if (!_stopped) return;
    _stopped = false;
    _pausedAt = null;
    setState(() => _loading = true);
    _controller.loadRequest(Uri.parse(_liveUrl)); // onPageFinished da el play
  }

  /// Abre el en vivo ampliado (con comentarios y rotación). Mientras
  /// está abierto, este reproductor se pausa para que no suene doble.
  Future<void> _openFullscreen() async {
    if (_fullscreenOpen || _stopped || !mounted) return;
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
  ///
  /// Los reintentos usan `autoplay`, que NO vuelve a reproducir un video
  /// que ya arrancó; así, si el usuario lo pausa con el botón del
  /// reproductor, se queda pausado. Con [force] el primer intento es un
  /// play forzado (al volver a la pestaña).
  void _applyState({bool force = false}) {
    if (_stopped) return;
    var firstRun = true;
    _scripts.run(
      () {
        final play = (force && firstRun)
            ? LiveWebScripts.play
            : LiveWebScripts.autoplay;
        firstRun = false;
        return [
          LiveWebScripts.hideFullscreenButton,
          widget.isActive ? play : LiveWebScripts.pause,
        ];
      },
      isAlive: () => mounted && !_stopped,
    );
  }

  @override
  void didUpdateWidget(covariant LiveChannelPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive == widget.isActive) return;
    if (_fullscreenOpen) return; // el ampliado manda sobre el estado

    if (widget.isActive) {
      // Hay un video encima: sigue apagado. Se reanuda al cerrarlo.
      if (_coordinator.hasVideoOpen) return;

      // Estaba apagado por un video: se vuelve a cargar el directo.
      if (_stopped) {
        _resume();
        return;
      }

      final pausedAt = _pausedAt;
      _pausedAt = null;
      final pausedLong = pausedAt != null &&
          DateTime.now().difference(pausedAt) > _reloadAfterPause;
      if (pausedLong) {
        // Recarga para volver al directo; onPageFinished da el play.
        setState(() => _loading = true);
        _controller.reload();
      } else {
        _applyState(force: true);
      }
    } else {
      if (_stopped) return; // ya está apagado
      _pausedAt = DateTime.now();
      _applyState(); // pausa
    }
  }

  @override
  void dispose() {
    _coordinator.removeListener(_onCoordinatorChanged);
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