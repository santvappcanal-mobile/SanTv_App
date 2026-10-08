import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../widgets/assistant_chat_sheet.dart';
import '../widgets/home/home_tab_content.dart';
import '../widgets/home/glass_bottom_nav_bar.dart';
import '../widgets/ads/ad_popup_dialog.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/ad_service.dart';
import '../services/live_status_service.dart';
import 'explore_screen.dart';
import 'live_tab_screen.dart';
import 'live_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'publicidad_screen.dart';
import 'admin_dashboard_screen.dart';
import 'settings_screen.dart';
import 'edit_profile_screen.dart';
import 'my_list_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.authService});

  final AuthService authService;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  // Índices de las pestañas dentro del IndexedStack / barra inferior.
  static const int _homeTabIndex = 0;
  static const int _liveTabIndex = 2;
  static const int _profileTabIndex = 3;

  // Cada cuánto se avisa al backend que el usuario sigue en la app.
  // Debe ser menor que la ventana de "activo" del backend (~2 min).
  static const Duration _pingInterval = Duration(seconds: 30);

  // Cambia a _liveTabIndex si quieres que la app abra directo en En vivo.
  int _currentIndex = _homeTabIndex;

  // Cuántas pantallas hay encima del Home (LiveScreen, notificaciones,
  // etc.). Mientras sea > 0 se pausan los reproductores que siguen
  // construidos debajo en el IndexedStack.
  int _covers = 0;

  // Se incrementa para que ProfileScreen vuelva a cargar los contadores
  // de Favoritos y Vistos (al entrar a la pestaña Perfil o volver de Mi Lista).
  int _profileRefresh = 0;

  AppUser? _currentUser;
  bool _loadingUser = true;

  Timer? _presenceTimer;

  late final NotificationService _notificationService = NotificationService(
    authService: widget.authService,
  );
  late final AdService _adService = AdService(authService: widget.authService);
  late final LiveStatusService _liveStatusService = LiveStatusService(
    baseUrl: widget.authService.baseUrl,
  );
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startPresence();
    _loadUser();
    _loadUnreadCount();
    _liveStatusService.connect(onLiveStarted: _onLiveStarted);
    _mostrarAnuncioAleatorio();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _presenceTimer?.cancel();
    _liveStatusService.dispose();
    super.dispose();
  }

  // ───────────────────────── Presencia ─────────────────────────

  /// Avisa que el usuario está dentro de la app y sigue avisando cada
  /// [_pingInterval] mientras la app esté en primer plano.
  void _startPresence() {
    _presenceTimer?.cancel();
    widget.authService.ping();
    _presenceTimer = Timer.periodic(
      _pingInterval,
      (_) => widget.authService.ping(),
    );
  }

  /// Deja de avisar y marca al usuario como fuera de la app.
  void _stopPresence() {
    _presenceTimer?.cancel();
    _presenceTimer = null;
    widget.authService.setOffline();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _startPresence();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _stopPresence();
        break;
      default:
        // inactive / hidden son transitorios (diálogos del sistema,
        // cambio de app): no se marca como desconectado todavía.
        break;
    }
  }

  // ───────────────────────── Datos ─────────────────────────

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

  /// Trae los anuncios activos, elige uno al azar y lo muestra en un
  /// modal cerrable. Se llama una vez al entrar al Home (cada sesión).
  Future<void> _mostrarAnuncioAleatorio() async {
    final todos = await _adService.obtenerAdsActivos();

    // NUEVO: los PDF legales (type: 'document') no se muestran en el modal.
    final ads = todos.where((a) => a.type != 'document').toList();
    if (!mounted || ads.isEmpty) return;

    final anuncio = ads[Random().nextInt(ads.length)];

    // pequeño delay para que el Home ya esté construido antes del modal
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    await AdPopupDialog.showAd(context, ad: anuncio, adService: _adService);
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
    // Solo se manda al chat una URL real; los avatares prediseñados
    // ("avatar:3") no son URLs y el chat los mostraría rotos.
    final avatar = _currentUser?.avatarUrl ?? '';
    final chatAvatarUrl = avatar.startsWith('http') ? avatar : '';

    await _pushCovered(
      MaterialPageRoute(
        builder: (_) => LiveScreen(
          liveId: liveId,
          title: 'SAN TV en vivo',
          description: 'Transmisión en vivo del canal SAN TV, 24/7.',
          coverImageUrl:
              'https://TU_IMAGEN_DE_PORTADA.jpg', // reemplaza con la portada real
          baseUrl: widget.authService.baseUrl,
          currentUser: {
            'id': _currentUser?.id ?? '',
            'name': _currentUser?.name ?? 'Usuario',
            'avatarUrl': chatAvatarUrl,
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

  /// Abre "Mi Lista" y, al volver, refresca los contadores del Perfil.
  Future<void> _openMyList() async {
    await _pushCovered(
      MaterialPageRoute(
        builder: (_) => MyListScreen(authService: widget.authService),
      ),
    );
    if (!mounted) return;
    setState(() => _profileRefresh++);
  }

  Future<void> _handleLogout() async {
    // Evita que un ping pendiente marque al usuario como activo otra vez.
    _presenceTimer?.cancel();
    _presenceTimer = null;
    await widget.authService.logout(); // ya llama a setOffline()
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  /// Abre la pantalla de Configuración.
  Future<void> _openSettings() async {
    if (_currentUser == null) return;
    await _pushCovered(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          authService: widget.authService,
          user: _currentUser!,
          onUserUpdated: (updatedUser) {
            setState(() => _currentUser = updatedUser);
          },
          onLogout: _handleLogout,
        ),
      ),
    );
  }

  /// Abre Editar perfil directo desde el círculo del avatar.
  Future<void> _openEditProfile() async {
    if (_currentUser == null) return;
    await _pushCovered(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          authService: widget.authService,
          user: _currentUser!,
          onSaved: (updated) => setState(() => _currentUser = updated),
        ),
      ),
    );
  }

  /// Cambio de pestaña desde la barra inferior. Al entrar al Perfil se
  /// refrescan los contadores (el IndexedStack no reconstruye la pantalla).
  void _onTabTap(int index) {
    setState(() {
      _currentIndex = index;
      if (index == _profileTabIndex) _profileRefresh++;
    });
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
                          authService: widget.authService,
                          refreshKey: _profileRefresh,
                          onEditProfile: _openEditProfile,
                          onMyList: _openMyList,
                          onAdvertising: _openAdvertising,
                          onSettings: _openSettings,
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
        onTap: _onTabTap,
        neonColor: neonColor,
      ),
    );
  }
}