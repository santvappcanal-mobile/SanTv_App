import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

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
  late final WebViewController _controller;
  bool _loading = true;

  static const _playJs = '''
    document.querySelectorAll('video').forEach(function(v){
      v.muted = false; v.play().catch(function(){ v.muted = true; v.play(); });
    });
  ''';
  static const _pauseJs =
      "document.querySelectorAll('video').forEach(function(v){ v.pause(); });";

  @override
  bool get wantKeepAlive => true; // no recarga el stream al cambiar de pestaña

  @override
  void initState() {
    super.initState();

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
      ..setBackgroundColor(const Color(0xFF0B0B0B))
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (!mounted) return;
          setState(() => _loading = false);
          if (widget.isActive) _controller.runJavaScript(_playJs);
        },
      ));

    if (_controller.platform is AndroidWebViewController) {
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false); // autoplay con sonido
    }

    _controller.loadRequest(Uri.parse(widget.streamUrl));
  }

  @override
  void didUpdateWidget(covariant LiveStreamPlayer old) {
    super.didUpdateWidget(old);
    if (old.isActive != widget.isActive) {
      _controller.runJavaScript(widget.isActive ? _playJs : _pauseJs);
    }
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