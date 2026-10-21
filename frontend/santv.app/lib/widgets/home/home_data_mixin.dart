import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../services/ad_service.dart';
import '../ads/ad_popup_dialog.dart';

/// Datos del Home: usuario, notificaciones sin leer y anuncio emergente.
mixin HomeDataMixin<T extends StatefulWidget> on State<T> {
  AuthService get authService;

  late final NotificationService notificationService =
      NotificationService(authService: authService);
  late final AdService adService = AdService(authService: authService);

  AppUser? currentUser;
  bool loadingUser = true;
  int unreadCount = 0;

  Future<void> loadUser() async {
    final user = await authService.getProfile();
    if (!mounted) return;
    setState(() {
      currentUser = user;
      loadingUser = false;
    });
  }

  Future<void> loadUnreadCount() async {
    final result = await notificationService.getNotifications();
    if (!mounted || !result.success) return;
    setState(() => unreadCount = result.unreadCount);
  }

  /// Trae los anuncios activos, elige uno al azar y lo muestra en un
  /// modal cerrable. Se llama una vez al entrar al Home (cada sesión).
  Future<void> mostrarAnuncioAleatorio() async {
    final todos = await adService.obtenerAdsActivos();

    // Los PDF legales (type: 'document') no se muestran en el modal.
    final ads = todos.where((a) => a.type != 'document').toList();
    if (!mounted || ads.isEmpty) return;

    final anuncio = ads[Random().nextInt(ads.length)];

    // pequeño delay para que el Home ya esté construido antes del modal
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    await AdPopupDialog.showAd(context, ad: anuncio, adService: adService);
  }
}