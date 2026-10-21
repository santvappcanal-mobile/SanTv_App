import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// Crea el WebViewController base de los reproductores en vivo:
/// JS activado, reproducción inline en iOS y autoplay con sonido en
/// Android. Cada pantalla le agrega su NavigationDelegate y la URL.
WebViewController createLiveWebController({Color background = Colors.black}) {
  late final PlatformWebViewControllerCreationParams params;
  if (WebViewPlatform.instance is WebKitWebViewPlatform) {
    params = WebKitWebViewControllerCreationParams(
      allowsInlineMediaPlayback: true,
      mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
    );
  } else {
    params = const PlatformWebViewControllerCreationParams();
  }

  final controller = WebViewController.fromPlatformCreationParams(params)
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(background);

  final platform = controller.platform;
  if (platform is AndroidWebViewController) {
    platform.setMediaPlaybackRequiresUserGesture(false);
  }
  return controller;
}