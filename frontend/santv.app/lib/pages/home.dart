import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../widgets/assistant_chat_sheet.dart';
import '../widgets/home/home_tab_content.dart';
import '../widgets/home/glass_bottom_nav_bar.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/ad_service.dart';
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

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  AppUser? _currentUser;
  bool _loadingUser = true;

  late final NotificationService _notificationService = NotificationService(
    authService: widget.authService,
  );
  late final AdService _adService = AdService(authService: widget.authService);
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadUnreadCount();
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

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
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
  void _openLive([String liveId = 'canal-en-vivo']) {
    Navigator.push(
      context,
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
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublicidadScreen(
          esAdmin: _currentUser?.isAdmin ?? false,
          adService: _adService,
        ),
      ),
    );
  }

  Future<void> _openAdminPanel() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminDashboardScreen(authService: widget.authService),
      ),
    );
  }

  Future<void> _handleLogout() async {
    await widget.authService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _openEditProfile() async {
    if (_currentUser == null) return;
    await Navigator.push(
      context,
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
                    onOpenLive: _openLive,
                    authService: widget.authService,
                  ),
                  ExploreScreen(
                    onOpenAdvertising: _openAdvertising,
                    authService: widget.authService,
                  ),
                  LiveTabScreen(
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