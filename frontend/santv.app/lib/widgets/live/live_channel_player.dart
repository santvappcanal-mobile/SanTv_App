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

/// Estado de pausa y silencio elegido por el usuario. Es compartido por
/// todos los reproductores del canal (Home y pestaña En vivo), así que
/// si pausa o silencia en uno, el otro queda igual.
class _SharedPlayerState {
  static final ValueNotifier<bool> paused = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> muted = ValueNotifier<bool>(false);
}

/// Reproductor del canal en vivo de SAN TV (WebView con autoplay).
/// Se usa en el Home y en la pestaña En vivo. Ambos cargan el mismo
/// directo, así que siempre están sincronizados.
///
/// [isActive] controla si debe sonar: solo el reproductor visible
/// reproduce, el otro se mantiene pausado.
/// [onTap], si se pasa, intercepta el toque sobre el video (ej. en el
/// Home para llevar a la pestaña En vivo). Los botones de pausa y
/// silencio van POR ENCIMA de ese toque, así que funcionan sin navegar.
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
    _SharedPlayerState.paused.addListener(_onUserPrefsChanged);
    _SharedPlayerState.muted.addListener(_onUserPrefsChanged);
  }

  /// Script que silencia o activa el sonido de todos los <video>/<audio>
  /// de la página (y de los iframes del mismo dominio).
  String _muteScript(bool muted) => '''
(function () {
  var MUTED = $muted;
  function apply(doc) {
    try {
      var els = doc.querySelectorAll('video,audio');
      for (var i = 0; i < els.length; i++) {
        els[i].muted = MUTED;
        if (!MUTED && els[i].volume === 0) els[i].volume = 1;
      }
    } catch (e) {}
  }
  apply(document);
  try {
    var frames = document.querySelectorAll('iframe');
    for (var j = 0; j < frames.length; j++) {
      try { apply(frames[j].contentDocument); } catch (e) {}
    }
  } catch (e) {}
})();
''';

  /// El usuario tocó pausa/play o silencio (en este reproductor o en el
  /// otro). Se vuelve a aplicar el estado.
  void _onUserPrefsChanged() {
    if (!mounted || _stopped || _fullscreenOpen) return;
    // force: si ahora NO está pausado, el primer intento es un play real.
    _applyState(force: !_SharedPlayerState.paused.value);
  }

  void _togglePause() {
    _SharedPlayerState.paused.value = !_SharedPlayerState.paused.value;
  }

  void _toggleMute() {
    _SharedPlayerState.muted.value = !_SharedPlayerState.muted.value;
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

  /// Aplica el estado actual: da play si está activo (y el usuario no lo
  /// pausó), pausa si no, y aplica el silencio elegido.
  /// Reintenta un rato porque el <video> puede aparecer tarde.
  ///
  /// Los reintentos usan `autoplay`, que NO vuelve a reproducir un video
  /// que ya arrancó; así, si el usuario lo pausa, se queda pausado. Con
  /// [force] el primer intento es un play forzado (al volver a la
  /// pestaña o cuando el usuario toca play).
  void _applyState({bool force = false}) {
    if (_stopped) return;
    var firstRun = true;
    _scripts.run(
      () {
        final userPaused = _SharedPlayerState.paused.value;
        final muted = _SharedPlayerState.muted.value;
        final play = (force && firstRun)
            ? LiveWebScripts.play
            : LiveWebScripts.autoplay;
        firstRun = false;
        return [
          LiveWebScripts.hideFullscreenButton,
          LiveWebScripts.hideWebControls,
          widget.isActive && !userPaused ? play : LiveWebScripts.pause,
          _muteScript(muted),
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
    _SharedPlayerState.paused.removeListener(_onUserPrefsChanged);
    _SharedPlayerState.muted.removeListener(_onUserPrefsChanged);
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
            // Controles propios: pausa/play, silencio y (solo en la
            // pestaña En vivo) ampliar. Van después del GestureDetector
            // del Home, por eso reciben el toque y NO navegan.
            Positioned(
              top: 10,
              right: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: _SharedPlayerState.paused,
                    builder: (_, paused, __) => RoundIconButton(
                      icon: paused
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      onTap: _togglePause,
                      size: 34,
                      alpha: 0.6,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ValueListenableBuilder<bool>(
                    valueListenable: _SharedPlayerState.muted,
                    builder: (_, muted, __) => RoundIconButton(
                      icon: muted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      onTap: _toggleMute,
                      size: 34,
                      alpha: 0.6,
                    ),
                  ),
                  if (widget.onTap == null) ...[
                    const SizedBox(width: 8),
                    RoundIconButton(
                      icon: Icons.fullscreen_rounded,
                      onTap: _openFullscreen,
                      size: 34,
                      alpha: 0.6,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}