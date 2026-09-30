import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../../widgets/live_tab/pulsing_live_dot.dart';
import '../../widgets/live_tab/featured_live_card.dart';
import '../../widgets/live_tab/live_grid_card.dart';

/// Pestaña "En Vivo". Se usa embebida dentro de [Home]
/// (pages/home.dart), como uno de los ítems del IndexedStack.
/// Muestra el canal en vivo permanente arriba (autoplay), y debajo
/// un listado de otras transmisiones/eventos en vivo puntuales.
class LiveTabScreen extends StatefulWidget {
  const LiveTabScreen({
    super.key,
    this.onOpenLive,
    this.isActive = true,
  });

  /// Se llama con el id del live seleccionado, para que Home/el
  /// router navegue a LiveScreen con ese contenido.
  final void Function(String liveId)? onOpenLive;

  /// true cuando la pestaña En vivo es la visible. Si es false el
  /// video se pausa (evita que suene mientras el usuario está en
  /// otra pestaña, ya que el IndexedStack mantiene todo construido).
  final bool isActive;

  // Datos de ejemplo. Reemplaza por tu lista real (backend/socket) de
  // eventos en vivo puntuales (LiveEvent), aparte del canal 24/7.
  static const _liveStreams = [
    {
      'id': 'live_1',
      'title': 'Liga Local - Final',
      'streamer': 'SAN TV Deportes',
      'viewers': 3421,
    },
    {
      'id': 'live_2',
      'title': 'Noticias de la tarde',
      'streamer': 'SAN TV Noticias',
      'viewers': 1288,
    },
  ];

  @override
  State<LiveTabScreen> createState() => _LiveTabScreenState();
}

class _LiveTabScreenState extends State<LiveTabScreen> {
  static const String _liveUrl =
      'https://streaminghd.co/user/produccionessantv';

  // Intenta reproducir todos los <video> de la página.
  static const String _playJs = '''
    document.querySelectorAll('video').forEach(function(v){
      v.muted = false;
      v.play().catch(function(){ v.muted = true; v.play(); });
    });
  ''';

  static const String _pauseJs =
      "document.querySelectorAll('video').forEach(function(v){ v.pause(); });";

  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    // En iOS hay que permitir reproducción inline y sin gesto del usuario.
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
            if (widget.isActive) _controller.runJavaScript(_playJs);
          },
        ),
      );

    // En Android: permitir autoplay sin que el usuario toque la pantalla.
    final platform = _controller.platform;
    if (platform is AndroidWebViewController) {
      platform.setMediaPlaybackRequiresUserGesture(false);
    }

    _controller.loadRequest(Uri.parse(_liveUrl));
  }

  @override
  void didUpdateWidget(covariant LiveTabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      _controller.runJavaScript(widget.isActive ? _playJs : _pauseJs);
    }
  }

  @override
  Widget build(BuildContext context) {
    final neonColor = Theme.of(context).colorScheme.primary;
    final rest = LiveTabScreen._liveStreams.skip(1).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              PulsingLiveDot(),
              SizedBox(width: 8),
              Text(
                'Canal en vivo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Canal permanente de SAN TV, reproduciéndose en autoplay.
          ClipRRect(
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
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Más transmisiones',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rest.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final stream = rest[index];
              return LiveGridCard(
                title: stream['title'] as String,
                viewers: stream['viewers'] as int,
                neonColor: neonColor,
                onTap: () => widget.onOpenLive?.call(stream['id'] as String),
              );
            },
          ),
        ],
      ),
    );
  }
}