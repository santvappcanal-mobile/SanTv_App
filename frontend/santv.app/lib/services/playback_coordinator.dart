import 'package:flutter/foundation.dart';

/// Coordina el audio entre el en vivo y los videos.
///
/// Las pantallas de video (`VideoPlayerScreen` y `YoutubePlayerScreen`)
/// llaman a [videoOpened] al abrirse y a [videoClosed] al cerrarse.
/// Los reproductores del en vivo (`LiveChannelPlayer` y
/// `LiveStreamPlayer`) escuchan este objeto y se apagan o se reanudan.
///
/// Usa un contador para que funcione bien aunque se abran varios videos
/// seguidos: el en vivo solo vuelve cuando se cierra el último.
class PlaybackCoordinator extends ChangeNotifier {
  PlaybackCoordinator._();

  static final PlaybackCoordinator instance = PlaybackCoordinator._();

  int _openVideos = 0;

  /// true mientras haya al menos un video abierto.
  bool get hasVideoOpen => _openVideos > 0;

  /// Se llama al abrir una pantalla de video.
  void videoOpened() {
    _openVideos++;
    if (_openVideos == 1) notifyListeners();
  }

  /// Se llama al cerrar una pantalla de video.
  void videoClosed() {
    if (_openVideos == 0) return;
    _openVideos--;
    if (_openVideos == 0) notifyListeners();
  }
}