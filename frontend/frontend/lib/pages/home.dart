import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import 'explore_screen.dart';
import 'live_tab_screen.dart';
import 'profile_screen.dart';
import 'edit_profile_screen.dart';
import 'notifications_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.authService});

  final AuthService authService;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  static const int _profileTabIndex = 3;

  AppUser? _currentUser;
  bool _loadingUser = true;

  late final NotificationService _notificationService =
      NotificationService(authService: widget.authService);
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
        builder: (_) => NotificationsScreen(
          notificationService: _notificationService,
        ),
      ),
    );
    _loadUnreadCount(); // refresca el contador al volver
  }

  Future<void> _handleLogout() async {
    await widget.authService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _goToProfileTab() {
    setState(() => _currentIndex = _profileTabIndex);
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
              onProfileTap: _goToProfileTab,
              onLogoutTap: _handleLogout,
              onNotificationsTap: _openNotifications,
              unreadCount: _unreadCount,
            ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  _buildHomeTab(neonColor),
                  const ExploreScreen(),
                  LiveTabScreen(
                    onOpenLive: (liveId) {
                      debugPrint('Abriendo transmisión: $liveId');
                    },
                  ),
                  _loadingUser
                      ? const Center(
                          child: CircularProgressIndicator(color: Color(0xFF39FF14)),
                        )
                      : ProfileScreen(
                          userName: _currentUser?.name ?? 'Usuario',
                          userEmail: _currentUser?.email ?? '',
                          avatarUrl: _currentUser?.avatarUrl,
                          onEditProfile: _openEditProfile,
                          onMyList: () {
                            // TODO: navega a "Mi Lista"
                          },
                          onSettings: () {
                            // TODO: navega a configuración
                          },
                          onHelp: () {
                            // TODO: navega a ayuda y soporte
                          },
                          onLogout: _handleLogout,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildGlassNavBar(neonColor),
    );
  }

  Widget _buildGlassNavBar(Color neonColor) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.03),
              ],
            ),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.15)),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: neonColor,
            unselectedItemColor: Colors.white38,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
              BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explorar'),
              BottomNavigationBarItem(icon: Icon(Icons.live_tv), label: 'En Vivo'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab(Color neonColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      neonColor.withOpacity(0.20),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                  boxShadow: [
                    BoxShadow(
                      color: neonColor.withOpacity(0.15),
                      blurRadius: 30,
                      spreadRadius: -8,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_fill, size: 60, color: neonColor),
                      const SizedBox(height: 10),
                      const Text(
                        'Canal en vivo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Videos destacados',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.08),
                              Colors.white.withOpacity(0.03),
                            ],
                          ),
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        child: const Center(
                          child: Text(
                            'Agregar Video',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}