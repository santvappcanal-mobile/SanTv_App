import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../pages/profile_screen.dart';

/// Pestaña de Perfil: muestra un loader mientras carga el usuario
/// y luego el ProfileScreen.
class HomeProfileTab extends StatelessWidget {
  const HomeProfileTab({
    super.key,
    required this.loading,
    required this.user,
    required this.authService,
    required this.refreshKey,
    required this.onEditProfile,
    required this.onMyList,
    required this.onAdvertising,
    required this.onSettings,
    required this.onHelp,
    required this.onLogout,
    required this.onAdminPanel,
  });

  final bool loading;
  final AppUser? user;
  final AuthService authService;
  final int refreshKey;
  final VoidCallback onEditProfile;
  final VoidCallback onMyList;
  final VoidCallback onAdvertising;
  final VoidCallback onSettings;
  final VoidCallback onHelp;
  final VoidCallback onLogout;
  final VoidCallback onAdminPanel;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF39FF14)),
      );
    }

    return ProfileScreen(
      userName: user?.name ?? 'Usuario',
      userEmail: user?.email ?? '',
      avatarUrl: user?.avatarUrl,
      isAdmin: user?.isAdmin ?? false,
      authService: authService,
      refreshKey: refreshKey,
      onEditProfile: onEditProfile,
      onMyList: onMyList,
      onAdvertising: onAdvertising,
      onSettings: onSettings,
      onHelp: onHelp,
      onLogout: onLogout,
      onAdminPanel: onAdminPanel,
    );
  }
}