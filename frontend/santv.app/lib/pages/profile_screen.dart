import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/watchlist_service.dart';
import '../widgets/profile/profile_header_card.dart';
import '../widgets/profile/profile_stats_row.dart';
import '../widgets/profile/profile_options_list.dart';
import '../widgets/profile/logout_button.dart';

/// Pestaña "Mi Perfil". Se usa embebida dentro de [Home]
/// (pages/home.dart), como uno de los ítems del IndexedStack.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    this.avatarUrl,
    this.isAdmin = false,
    this.authService,
    this.refreshKey = 0,
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

  /// Necesario para leer los contadores reales (Favoritos y Vistos).
  /// Si es null, los contadores se quedan en 0.
  final AuthService? authService;

  /// Cada vez que este número cambia, se vuelven a cargar los contadores.
  /// Home lo incrementa al entrar a la pestaña Perfil o al volver de Mi Lista.
  final int refreshKey;

  final VoidCallback? onMyList;
  final VoidCallback? onAdvertising;
  final VoidCallback? onSettings;
  final VoidCallback? onHelp;
  final VoidCallback? onLogout;
  final VoidCallback? onAdminPanel;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  WatchlistService? _watchlistService;
  int _favorites = 0;
  int _watched = 0;

  @override
  void initState() {
    super.initState();
    final auth = widget.authService;
    if (auth != null) {
      _watchlistService = WatchlistService(authService: auth);
      _cargarStats();
    }
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey) {
      _cargarStats();
    }
  }

  Future<void> _cargarStats() async {
    final service = _watchlistService;
    if (service == null) return;

    final stats = await service.obtenerStats();
    if (!mounted || stats == null) return;

    setState(() {
      _favorites = stats.favorites;
      _watched = stats.watched;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Home usa extendBody: true, así que la barra de navegación flotante y el
    // botón del chatbot quedan encima del contenido. Este espacio extra permite
    // deslizar hasta que el botón de cerrar sesión quede visible por encima.
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileHeaderCard(
            userName: widget.userName,
            userEmail: widget.userEmail,
            avatarUrl: widget.avatarUrl,
          ),
          const SizedBox(height: 18),
          ProfileStatsRow(favorites: _favorites, watched: _watched),
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
                onTap: widget.onMyList,
              ),
              ProfileMenuOption(
                icon: Icons.campaign_outlined,
                label: 'Publicidad',
                onTap: widget.onAdvertising,
              ),
              ProfileMenuOption(
                icon: Icons.settings_outlined,
                label: 'Configuración',
                onTap: widget.onSettings,
              ),
              ProfileMenuOption(
                icon: Icons.help_outline,
                label: 'Ayuda y soporte',
                onTap: widget.onHelp,
              ),
              if (widget.isAdmin)
                ProfileMenuOption(
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Panel de Admin',
                  onTap: widget.onAdminPanel,
                ),
            ],
          ),
          const SizedBox(height: 24),
          LogoutButton(onLogout: widget.onLogout),
        ],
      ),
    );
  }
}