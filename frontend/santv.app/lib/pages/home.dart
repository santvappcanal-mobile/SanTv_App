import 'package:flutter/material.dart';
import '../widgets/home/presence_mixin.dart';
import '../widgets/home/home_data_mixin.dart';
import '../widgets/home/home_navigation_mixin.dart';
import '../widgets/home/home_push_mixin.dart';
import '../services/auth_service.dart';
import '../services/live_status_service.dart';
import '../widgets/top_bar.dart';
import '../widgets/home/home_tab_content.dart';
import '../widgets/home/glass_bottom_nav_bar.dart';
import '../widgets/home/home_gradient_background.dart';
import '../widgets/home/live_started_snack_bar.dart';
import '../widgets/home/assistant_fab.dart';
import '../widgets/home/home_profile_tab.dart';
import 'explore_screen.dart';
import 'live_tab_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.authService});

  final AuthService authService;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>
    with WidgetsBindingObserver, PresenceMixin<Home>, HomeDataMixin<Home>,
        HomeNavigationMixin<Home>, HomePushMixin<Home> {
  late final LiveStatusService _liveStatus =
      LiveStatusService(baseUrl: widget.authService.baseUrl);

  @override
  AuthService get authService => widget.authService;

  @override
  void initState() {
    super.initState();
    loadUser();
    loadUnreadCount();
    _liveStatus.connect(onLiveStarted: _onLiveStarted);
    mostrarAnuncioAleatorio();

    // Notificaciones push: registra el teléfono y escucha los avisos.
    initPush();
  }

  @override
  void dispose() {
    _liveStatus.dispose();
    disposePush();
    super.dispose();
  }

  /// El canal pasó a EN VIVO: refresca notificaciones y avisa.
  void _onLiveStarted(String title, String message) {
    if (!mounted) return;
    loadUnreadCount();
    LiveStartedSnackBar.show(context,
        title: title, message: message, onView: goToLive);
  }

  @override
  Widget build(BuildContext context) {
    final neonColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      extendBody: true,
      body: HomeGradientBackground(
        child: Column(
          children: [
            TopBar(onNotificationsTap: openNotifications, unreadCount: unreadCount),
            Expanded(
              child: IndexedStack(
                index: currentIndex,
                children: [
                  HomeTabContent(
                    neonColor: neonColor,
                    onOpenAdvertising: openAdvertising,
                    authService: authService,
                    isActive: homeActive,
                    onOpenLiveTab: goToLive,
                  ),
                  ExploreScreen(
                    onOpenAdvertising: openAdvertising,
                    authService: authService,
                  ),
                  LiveTabScreen(
                    isActive: liveActive,
                    onOpenLive: (liveId) => openLive(liveId),
                    authService: authService,
                  ),
                  HomeProfileTab(
                    loading: loadingUser,
                    user: currentUser,
                    authService: authService,
                    refreshKey: profileRefresh,
                    onEditProfile: openEditProfile,
                    onMyList: openMyList,
                    onAdvertising: openAdvertising,
                    onSettings: openSettings,
                    onHelp: () {}, // TODO: navega a ayuda y soporte
                    onLogout: handleLogout,
                    onAdminPanel: openAdminPanel,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          AssistantFab(onPressed: openAssistantChat, neonColor: neonColor),
      bottomNavigationBar: GlassBottomNavBar(
        currentIndex: currentIndex,
        onTap: onTabTap,
        neonColor: neonColor,
      ),
    );
  }
}