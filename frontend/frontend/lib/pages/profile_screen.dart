import 'package:flutter/material.dart';
import '../widgets/profile/profile_header_card.dart';
import '../widgets/profile/profile_stats_row.dart';
import '../widgets/profile/profile_options_list.dart';
import '../widgets/profile/logout_button.dart';

/// Pestaña "Mi Perfil". Se usa embebida dentro de [Home]
/// (pages/home.dart), como uno de los ítems del IndexedStack.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    this.avatarUrl,
    this.isAdmin = false,
    this.onEditProfile,
    this.onMyList,
    this.onAdvertising,
    this.onSettings,
    this.onHelp,
    this.onLogout,
    this.onAdminPanel,
  });

  final String userName;
  final String userEmail;
  final String? avatarUrl;
  final bool isAdmin;

  final VoidCallback? onEditProfile;
  final VoidCallback? onMyList;
  final VoidCallback? onAdvertising;
  final VoidCallback? onSettings;
  final VoidCallback? onHelp;
  final VoidCallback? onLogout;
  final VoidCallback? onAdminPanel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileHeaderCard(
            userName: userName,
            userEmail: userEmail,
            avatarUrl: avatarUrl,
            onEditProfile: onEditProfile,
          ),
          const SizedBox(height: 18),
          const ProfileStatsRow(),
          const SizedBox(height: 24),
          const Text(
            'Cuenta',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ProfileOptionsList(
            options: [
              ProfileMenuOption(
                icon: Icons.bookmark_outline,
                label: 'Mi Lista',
                onTap: onMyList,
              ),
              ProfileMenuOption(
                icon: Icons.campaign_outlined,
                label: 'Publicidad',
                onTap: onAdvertising,
              ),
              ProfileMenuOption(
                icon: Icons.settings_outlined,
                label: 'Configuración',
                onTap: onSettings,
              ),
              ProfileMenuOption(
                icon: Icons.help_outline,
                label: 'Ayuda y soporte',
                onTap: onHelp,
              ),
              if (isAdmin)
                ProfileMenuOption(
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Panel de Admin',
                  onTap: onAdminPanel,
                ),
            ],
          ),
          const SizedBox(height: 24),
          LogoutButton(onLogout: onLogout),
        ],
      ),
    );
  }
}
