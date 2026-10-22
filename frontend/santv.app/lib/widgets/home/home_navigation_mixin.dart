import 'package:flutter/material.dart';
import '../../pages/live_screen.dart';
import '../../pages/notifications_screen.dart';
import '../../pages/publicidad_screen.dart';
import '../../pages/admin_dashboard_screen.dart';
import '../../pages/settings_screen.dart';
import '../../pages/edit_profile_screen.dart';
import '../../pages/my_list_screen.dart';
import '../../services/push_notification_service.dart';
import '../assistant_chat_sheet.dart';
import 'home_data_mixin.dart';
import 'presence_mixin.dart';

/// Navegación del Home: abre pantallas encima y marca el Home como
/// "cubierto" para pausar los videos que quedan debajo.
mixin HomeNavigationMixin<T extends StatefulWidget>
    on State<T>, PresenceMixin<T>, HomeDataMixin<T> {
  // Índices de las pestañas dentro del IndexedStack / barra inferior.
  static const int _homeTab = 0;
  static const int _liveTab = 2;
  static const int _profileTab = 3;

  // Cambia a _liveTab si quieres que la app abra directo en En vivo.
  int currentIndex = _homeTab;

  // Cuántas pantallas hay encima del Home. Mientras sea > 0 se pausan
  // los reproductores que siguen construidos en el IndexedStack.
  int covers = 0;

  // Se incrementa para que ProfileScreen recargue Favoritos y Vistos.
  int profileRefresh = 0;

  bool get notCovered => covers == 0;

  // true cuando la pestaña es visible y no hay pantallas encima
  // (para pausar los videos de las otras pestañas).
  bool get homeActive => currentIndex == _homeTab && notCovered;
  bool get liveActive => currentIndex == _liveTab && notCovered;

  void goToLive() => setState(() => currentIndex = _liveTab);

  /// Al entrar al Perfil se refrescan los contadores (IndexedStack).
  void onTabTap(int index) => setState(() {
        currentIndex = index;
        if (index == _profileTab) profileRefresh++;
      });

  Future<R?> pushCovered<R>(Route<R> route) async {
    setState(() => covers++);
    try {
      return await Navigator.push<R>(context, route);
    } finally {
      if (mounted) setState(() => covers--);
    }
  }

  Future<void> openNotifications() async {
    await pushCovered(MaterialPageRoute(
      builder: (_) =>
          NotificationsScreen(notificationService: notificationService),
    ));
    loadUnreadCount(); // refresca el contador al volver
  }

  void openAssistantChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AssistantChatSheet(authService: authService),
    );
  }

  /// Abre el canal en vivo (24/7). [liveId] permite otras transmisiones.
  Future<void> openLive([String liveId = 'canal-en-vivo']) async {
    // Solo se manda al chat una URL real; los avatares prediseñados
    // ("avatar:3") no son URLs y el chat los mostraría rotos.
    final avatar = currentUser?.avatarUrl ?? '';
    final chatAvatarUrl = avatar.startsWith('http') ? avatar : '';

    await pushCovered(MaterialPageRoute(
      builder: (_) => LiveScreen(
        liveId: liveId,
        title: 'SAN TV en vivo',
        description: 'Transmisión en vivo del canal SAN TV, 24/7.',
        coverImageUrl:
            'https://TU_IMAGEN_DE_PORTADA.jpg', // reemplaza con la portada real
        baseUrl: authService.baseUrl,
        currentUser: {
          'id': currentUser?.id ?? '',
          'name': currentUser?.name ?? 'Usuario',
          'avatarUrl': chatAvatarUrl,
        },
      ),
    ));
  }

  Future<void> openAdvertising() async {
    await pushCovered(MaterialPageRoute(
      builder: (_) => PublicidadScreen(
        esAdmin: currentUser?.isAdmin ?? false,
        adService: adService,
      ),
    ));
  }

  Future<void> openAdminPanel() async {
    await pushCovered(MaterialPageRoute(
      builder: (_) => AdminDashboardScreen(authService: authService),
    ));
  }

  /// Abre "Mi Lista" y, al volver, refresca los contadores del Perfil.
  Future<void> openMyList() async {
    await pushCovered(MaterialPageRoute(
      builder: (_) => MyListScreen(authService: authService),
    ));
    if (!mounted) return;
    setState(() => profileRefresh++);
  }

  Future<void> openSettings() async {
    if (currentUser == null) return;
    await pushCovered(MaterialPageRoute(
      builder: (_) => SettingsScreen(
        authService: authService,
        user: currentUser!,
        onUserUpdated: (updated) => setState(() => currentUser = updated),
        onLogout: handleLogout,
      ),
    ));
  }

  Future<void> openEditProfile() async {
    if (currentUser == null) return;
    await pushCovered(MaterialPageRoute(
      builder: (_) => EditProfileScreen(
        authService: authService,
        user: currentUser!,
        onSaved: (updated) => setState(() => currentUser = updated),
      ),
    ));
  }

  Future<void> handleLogout() async {
    // Evita que un ping pendiente marque al usuario como activo otra vez.
    cancelPresenceTimer();
    // Este teléfono deja de recibir las notificaciones de este usuario.
    await PushNotificationService.instance.unregisterDevice(authService);
    await authService.logout(); // ya llama a setOffline()
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}