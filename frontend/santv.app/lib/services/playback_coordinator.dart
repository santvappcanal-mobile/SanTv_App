import 'dart:async';
import 'package:flutter/foundation.dart';

/// Coordina el sonido entre el en vivo y los videos para que nunca
/// suenen al mismo tiempo.
///
/// - Las pantallas de video (normal y YouTube) llaman a [videoOpened]
///   al abrirse y a [videoClosed] al cerrarse.
/// - Los reproductores del en vivo escuchan este objeto: mientras
///   [videoOpen] sea true se mantienen pausados, y al cerrarse el
///   video vuelven a sonar (si su pestaña sigue visible).
class PlaybackCoordinator extends ChangeNotifier {
  PlaybackCoordinator._();

  static final PlaybackCoordinator instance = PlaybackCoordinator._();

  int _open = 0;

  /// true mientras haya al menos una pantalla de video abierta.
  bool get videoOpen => _open > 0;

  void videoOpened() {
    _open++;
    _notifyLater();
  }

  void videoClosed() {
    if (_open > 0) _open--;
    _notifyLater();
  }

  /// Se avisa en un microtask para no llamar a setState de otros
  /// widgets mientras Flutter está construyendo o destruyendo pantallas.
  void _notifyLater() => scheduleMicrotask(notifyListeners);
}