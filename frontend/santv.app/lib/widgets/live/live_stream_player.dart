import 'dart:async';

import 'package:flutter/material.dart';
import 'package:santv_app/services/playback_coordinator.dart';
import 'package:santv_app/widgets/live/live_web_controller.dart';
import 'package:santv_app/widgets/live/live_web_scripts.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LiveStreamPlayer extends StatefulWidget {
  /// true = la pestaña En vivo está visible (suena); false = se pausa.
  final bool isActive;
  final String streamUrl;

  const LiveStreamPlayer({
    super.key,
    required this.isActive,
    this.streamUrl = 'https://streaminghd.co/user/produccionessantv',
  });

  @override
  State<LiveStreamPlayer> createState() => _LiveStreamPlayerState();
}

class _LiveStreamPlayerState extends State<LiveStreamPlayer>
    with AutomaticKeepAliveClientMixin {
  static const String _blankUrl = 'about:blank';

  final PlaybackCoordinator _coordinator = PlaybackCoordinator.instance;

  late final WebViewController _controller;
  bool _loading = true;

  /// true cuando el en vivo está apagado (WebView en about:blank)
  /// porque hay un video abierto encima.
  bool _stopped = false;

  @override
  bool get wantKeepAlive => true; // no recarga el stream al cambiar de pestaña

  @override
  void initState() {
    super.initState();
    _controller = createLiveWebController(background: const Color(0xFF0B0B0B))
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          if (!mounted || _stopped || url.startsWith(_blankUrl)) return;
          setState(() => _loading = false);
          if (widget.isActive && !_coordinator.hasVideoOpen) {
            _controller.runJavaScript(LiveWebScripts.play);
          }
        },
      ))
      ..loadRequest(Uri.parse(widget.streamUrl));

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
      } else if (widget.isActive) {
        _resume();
      }
    });
  }

  /// Apaga el en vivo: pausa y descarga la página para que no suene nada.
  void _stopHard() {
    if (_stopped) return;
    _stopped = true;
    _controller.runJavaScript(LiveWebScripts.pause);
    _controller.loadRequest(Uri.parse(_blankUrl));
  }

  /// Vuelve a cargar el directo si estaba apagado.
  void _resume() {
    if (!_stopped) return;
    _stopped = false;
    setState(() => _loading = true);
    _controller.loadRequest(Uri.parse(widget.streamUrl)); // onPageFinished da el play
  }

  @override
  void didUpdateWidget(covariant LiveStreamPlayer old) {
    super.didUpdateWidget(old);
    if (old.isActive == widget.isActive) return;

    if (widget.isActive) {
      // Hay un video encima: sigue apagado. Se reanuda al cerrarlo.
      if (_coordinator.hasVideoOpen) return;

      if (_stopped) {
        _resume();
        return;
      }
      _controller.runJavaScript(LiveWebScripts.play);
    } else {
      if (_stopped) return; // ya está apagado
      _controller.runJavaScript(LiveWebScripts.pause);
    }
  }

  @override
  void dispose() {
    _coordinator.removeListener(_onCoordinatorChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const ColoredBox(
              color: Color(0xFF0B0B0B),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF39FF14)),
              ),
            ),
        ],
      ),
    );
  }
  
}