import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

/// Avisa al backend que el usuario está en la app (ping cada 30 s)
/// y lo marca como desconectado cuando la app pasa a segundo plano.
mixin PresenceMixin<T extends StatefulWidget>
    on State<T>, WidgetsBindingObserver {
  // Debe ser menor que la ventana de "activo" del backend (~2 min).
  static const Duration _pingInterval = Duration(seconds: 30);

  Timer? _presenceTimer;

  AuthService get authService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    startPresence();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cancelPresenceTimer();
    super.dispose();
  }

  /// Avisa que el usuario está dentro y sigue avisando cada [_pingInterval].
  void startPresence() {
    _presenceTimer?.cancel();
    authService.ping();
    _presenceTimer = Timer.periodic(_pingInterval, (_) => authService.ping());
  }

  /// Solo detiene el timer (se usa antes del logout).
  void cancelPresenceTimer() {
    _presenceTimer?.cancel();
    _presenceTimer = null;
  }

  /// Deja de avisar y marca al usuario como fuera de la app.
  void stopPresence() {
    cancelPresenceTimer();
    authService.setOffline();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        startPresence();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        stopPresence();
        break;
      default:
        // inactive / hidden son transitorios (diálogos del sistema,
        // cambio de app): no se marca como desconectado todavía.
        break;
    }
  }
}