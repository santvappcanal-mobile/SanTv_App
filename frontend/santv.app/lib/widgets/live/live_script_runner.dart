import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';

/// Ejecuta scripts JS en el WebView y los reintenta un rato, porque los
/// reproductores web crean el <video> unos segundos después de cargar.
class LiveScriptRunner {
  LiveScriptRunner(this._controller);

  static const Duration retryEvery = Duration(milliseconds: 1500);
  static const int maxAttempts = 14;

  final WebViewController _controller;
  Timer? _timer;

  /// Corre [scripts] ya y luego cada [retryEvery] hasta [maxAttempts].
  /// [isAlive] corta los reintentos si la pantalla ya no está montada.
  void run(
    List<String> Function() scripts, {
    required bool Function() isAlive,
  }) {
    cancel();
    var attempts = 0;

    void execute() {
      for (final js in scripts()) {
        _controller.runJavaScript(js);
      }
    }

    execute();
    _timer = Timer.periodic(retryEvery, (t) {
      attempts++;
      if (!isAlive() || attempts >= maxAttempts) {
        t.cancel();
        return;
      }
      execute();
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}