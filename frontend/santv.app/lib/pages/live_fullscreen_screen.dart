import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:santv_app/services/auth_service.dart';
import 'package:santv_app/services/live_comment_service.dart';
import 'package:santv_app/widgets/live/live_fullscreen_comments.dart';
import 'package:santv_app/widgets/live/live_fullscreen_video.dart';
import 'package:santv_app/widgets/live/live_script_runner.dart';
import 'package:santv_app/widgets/live/live_web_controller.dart';
import 'package:santv_app/widgets/live/live_web_scripts.dart';
import 'package:santv_app/widgets/live/round_icon_button.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  late final WebViewController _web;
  late final LiveScriptRunner _scripts;
  final GlobalKey _webKey = GlobalKey();
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

    _web = createLiveWebController()
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _loading = false);
            _applyScripts();
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.streamUrl));

    _scripts = LiveScriptRunner(_web);
  }

  /// El <video> puede aparecer tarde, por eso se reintenta un rato.
  void _applyScripts() {
    _scripts.run(
      () => [LiveWebScripts.hideFullscreenButton, LiveWebScripts.fitVideo],
      isAlive: () => mounted,
    );
  }

  @override
  void dispose() {
    _scripts.cancel();
    _web.runJavaScript(LiveWebScripts.pause);
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
    final landscape = size.width > size.height;
    final comments = _comments;

    // Mismos widgets en ambas orientaciones (solo cambia su posición),
    // así el WebView no se recarga al girar el teléfono.
    final double videoHeight = landscape ? size.height : size.width * 9 / 16;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          LiveFullscreenVideo(
            controller: _web,
            webKey: _webKey,
            loading: _loading,
            height: videoHeight,
          ),
          if (comments != null)
            LiveFullscreenComments(
              service: comments,
              landscape: landscape,
              videoHeight: videoHeight,
            ),
          Positioned(
            top: 8 + pad.top,
            right: 8 + pad.right,
            child: RoundIconButton(
              icon: Icons.fullscreen_exit_rounded,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
    );
  }
}