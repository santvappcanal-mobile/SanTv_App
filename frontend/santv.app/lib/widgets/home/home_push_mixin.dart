import 'dart:async';

import 'package:flutter/material.dart';
import '../../services/push_action_handler.dart';
import '../../services/push_notification_service.dart';
import 'home_data_mixin.dart';
import 'home_navigation_mixin.dart';
import 'presence_mixin.dart';

/// Notificaciones push (Firebase) del Home:
/// - registra este teléfono en el servidor para recibir avisos con la app cerrada,
/// - muestra un aviso dentro de la app cuando llega uno con la app abierta,
/// - lleva al usuario a la pantalla correcta cuando toca una notificación.
mixin HomePushMixin<T extends StatefulWidget>
    on State<T>, PresenceMixin<T>, HomeDataMixin<T>, HomeNavigationMixin<T> {
  late final PushActionHandler _pushActions =
      PushActionHandler(authService: authService);
  StreamSubscription<PushPayload>? _pushForegroundSub;
  StreamSubscription<Map<String, dynamic>>? _pushTapSub;

  /// Llamar en initState (después de super.initState()).
  void initPush() {
    final push = PushNotificationService.instance;

    push.registerDevice(authService);
    _pushForegroundSub = push.onForeground.listen(_onPushForeground);
    _pushTapSub = push.onTap.listen(_onPushTap);

    // Si la app se abrió tocando una notificación (estaba cerrada).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pending = push.takePendingTap();
      if (pending != null) _onPushTap(pending);
    });
  }

  /// Llamar en dispose (antes de super.dispose()).
  void disposePush() {
    _pushForegroundSub?.cancel();
    _pushTapSub?.cancel();
  }

  /// Llegó un push con la app abierta: actualiza el contador y muestra un
  /// aviso. Los de "en vivo" ya los muestra _onLiveStarted (por socket).
  void _onPushForeground(PushPayload push) {
    if (!mounted) return;
    loadUnreadCount();
    if (push.data['type'] == 'live_event') return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1A1A1A),
        duration: const Duration(seconds: 6),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              push.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(push.body, style: const TextStyle(color: Colors.white70)),
          ],
        ),
        action: SnackBarAction(
          label: 'VER',
          textColor: const Color(0xFF39FF14),
          onPressed: () => _onPushTap(push.data),
        ),
      ),
    );
  }

  /// El usuario tocó una notificación push: lo lleva a la pantalla indicada.
  Future<void> _onPushTap(Map<String, dynamic> data) async {
    if (!mounted) return;
    loadUnreadCount();

    if (data['type'] == 'live_event') {
      goToLive();
      return;
    }

    final route = await _pushActions.routeFor(data);
    if (route == null || !mounted) return;
    await pushCovered(route);
  }
}
