import 'dart:async';

import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../widgets/assistant_chat_sheet.dart';
import '../widgets/home/home_tab_content.dart';
import '../widgets/home/glass_bottom_nav_bar.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/ad_service.dart';
import '../services/live_status_service.dart';
import 'explore_screen.dart';
import 'live_tab_screen.dart';
import 'live_screen.dart';
import 'profile_screen.dart';
import 'edit_profile_screen.dart';
import 'notifications_screen.dart';
import 'publicidad_screen.dart';
import 'admin_dashboard_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.authService});

  final AuthService authService;

  @override
  State<Home> createState() => _HomeState();
}

<<<<<<< Updated upstream
class _HomeState extends State<Home> with WidgetsBindingObserver {
  // Índice de la pestaña En vivo dentro del IndexedStack / barra inferior.
=======
class _HomeState extends State<Home> {
  // Índices de las pestañas dentro del IndexedStack / barra inferior.
  static const int _homeTabIndex = 0;
>>>>>>> Stashed changes
  static const int _liveTabIndex = 2;

  // Cambia a _liveTabIndex si quieres que la app abra directo en En vivo.
  int _currentIndex = _homeTabIndex;

  // Cuántas pantallas hay encima del Home (LiveScreen, notificaciones,
  // etc.). Mientras sea > 0 se pausan los reproductores que siguen
  // construidos debajo en el IndexedStack.
  int _covers = 0;

  AppUser? _currentUser;
  bool _loadingUser = true;

  late final NotificationService _notificationService = NotificationService(
    authService: widget.authService,
  );
  late final AdService _adService = AdService(authService: widget.authService);
  late final LiveStatusService _liveStatusService = LiveStatusService(
    baseUrl: widget.authService.baseUrl,
  );
  int _unreadCount = 0;

  // Presencia: avisa al backend que el usuario está dentro de la app.
  Timer? _presenceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startPresence();
    _loadUser();
    _loadUnreadCount();
    _liveStatusService.connect(onLiveStarted: _onLiveStarted);
  }

  @override
  void dispose() {
    _liveStatusService.dispose();
    super.dispose();
  }

  void _startPresence() {
    _presenceTimer?.cancel();
    widget.authService.ping();
    _presenceTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => widget.authService.ping(),
    );
  }

  void _stopPresence() {
    _presenceTimer?.cancel();
    _presenceTimer = null;
    widget.authService.setOffline();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startPresence();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _stopPresence();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _presenceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await widget.authService.getProfile();
    if (!mounted) return;
    setState(() {
      _currentUser = user;
      _loadingUser = false;
    });
  }

  Future<void> _loadUnreadCount() async {
    final result = await _notificationService.getNotifications();
    if (!mounted || !result.success) return;
    setState(() => _unreadCount = result.unreadCount);
  }

  /// El canal acaba de pasar a EN VIVO: refresca el contador de
  /// notificaciones y muestra un aviso con acceso directo.
  void _onLiveStarted(String title, String message) {
    if (!mounted) return;
    _loadUnreadCount();

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1A1A1A),
        duration: const Duration(seconds: 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(message, style: const TextStyle(color: Colors.white70)),
          ],
        ),
        action: SnackBarAction(
          label: 'VER',
          textColor: const Color(0xFF39FF14),
          onPressed: () {
            if (!mounted) return;
            setState(() => _currentIndex = _liveTabIndex);
          },
        ),
      ),
    );
  }

  /// Abre una pantalla encima del Home y mientras tanto marca el Home
  /// como "cubierto" para que los videos se pausen.
  Future<T?> _pushCovered<T>(Route<T> route) async {
    setState(() => _covers++);
    try {
      return await Navigator.push<T>(context, route);
    } finally {
      if (mounted) setState(() => _covers--);
    }
  }

  Future<void> _openNotifications() async {
    await _pushCovered(
      MaterialPageRoute(
        builder: (_) =>
            NotificationsScreen(notificationService: _notificationService),
      ),
    );
    _loadUnreadCount(); // refresca el contador al volver
  }

  void _openAssistantChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AssistantChatSheet(authService: widget.authService),
    );
  }

  /// Abre la pantalla del canal en vivo (siempre activo, 24/7).
  /// [liveId] permite reutilizar esto para otras transmisiones futuras;
  /// para el canal permanente usamos un id fijo.
  Future<void> _openLive([String liveId = 'canal-en-vivo']) async {
    await _pushCovered(
      MaterialPageRoute(
        builder: (_) => LiveScreen(
          liveId: liveId,
          title: 'SAN TV en vivo',
          description: 'Transmisión en vivo del canal SAN TV, 24/7.',
          coverImageUrl:
              'https://TU_IMAGEN_DE_PORTADA.jpg', // reemplaza con la portada real
          currentUser: {
            'id': _currentUser?.id ?? '',
            'name': _currentUser?.name ?? 'Usuario',
            'avatarUrl': _currentUser?.avatarUrl ?? '',
          },
        ),
      ),
    );
  }

  Future<void> _openAdvertising() async {
    await _pushCovered(
      MaterialPageRoute(
        builder: (_) => PublicidadScreen(
          esAdmin: _currentUser?.isAdmin ?? false,
          adService: _adService,
        ),
      ),
    );
  }

  Future<void> _openAdminPanel() async {
    await _pushCovered(
      MaterialPageRoute(
        builder: (_) => AdminDashboardScreen(authService: widget.authService),
      ),
    );
  }

  Future<void> _handleLogout() async {
    _presenceTimer?.cancel(); // evita un ping después de cerrar sesión
    await widget.authService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _openEditProfile() async {
    if (_currentUser == null) return;
    await _pushCovered(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          authService: widget.authService,
          user: _currentUser!,
          onSaved: (updatedUser) {
            setState(() => _currentUser = updatedUser);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final neonColor = Theme.of(context).colorScheme.primary;
    final notCovered = _covers == 0;

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B0B0B), Color(0xFF10241A), Color(0xFF0B0B0B)],
          ),
        ),
        child: Column(
          children: [
            TopBar(
              onNotificationsTap: _openNotifications,
              unreadCount: _unreadCount,
            ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  HomeTabContent(
                    neonColor: neonColor,
                    onOpenAdvertising: _openAdvertising,
                    authService: widget.authService,
                    isActive: _currentIndex == _homeTabIndex && notCovered,
                    onOpenLiveTab: () =>
                        setState(() => _currentIndex = _liveTabIndex),
                  ),
                  ExploreScreen(
                    onOpenAdvertising: _openAdvertising,
                    authService: widget.authService,
                  ),
                  LiveTabScreen(
                    isActive: _currentIndex == _liveTabIndex && notCovered,
                    onOpenLive: (liveId) => _openLive(liveId),
                  ),
                  _loadingUser
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF39FF14),
                          ),
                        )
                      : ProfileScreen(
                          userName: _currentUser?.name ?? 'Usuario',
                          userEmail: _currentUser?.email ?? '',
                          avatarUrl: _currentUser?.avatarUrl,
                          isAdmin: _currentUser?.isAdmin ?? false,
                          onEditProfile: _openEditProfile,
                          onMyList: () {
                            // TODO: navega a "Mi Lista"
                          },
                          onAdvertising: _openAdvertising,
                          onSettings: () {
                            // TODO: navega a configuración
                          },
                          onHelp: () {
                            // TODO: navega a ayuda y soporte
                          },
                          onLogout: _handleLogout,
                          onAdminPanel: _openAdminPanel,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAssistantChat,
        backgroundColor: neonColor,
        child: const Icon(Icons.smart_toy_outlined, color: Colors.black),
      ),
      bottomNavigationBar: GlassBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        neonColor: neonColor,
      ),
    );
  }
}
