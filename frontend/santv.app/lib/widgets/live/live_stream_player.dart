import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:santv_app/widgets/live/live_web_controller.dart';
import 'package:santv_app/widgets/live/live_web_scripts.dart';

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

  @override
  bool get wantKeepAlive => true; // no recarga el stream al cambiar de pestaña

  @override
  void initState() {
    super.initState();
    _controller = createLiveWebController(background: const Color(0xFF0B0B0B))
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (!mounted) return;
          setState(() => _loading = false);
          if (widget.isActive) _controller.runJavaScript(LiveWebScripts.play);
        },
      ))
      ..loadRequest(Uri.parse(widget.streamUrl));
  }

  @override
  void didUpdateWidget(covariant LiveStreamPlayer old) {
    super.didUpdateWidget(old);
    if (old.isActive != widget.isActive) {
      _controller.runJavaScript(
        widget.isActive ? LiveWebScripts.play : LiveWebScripts.pause,
      );
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