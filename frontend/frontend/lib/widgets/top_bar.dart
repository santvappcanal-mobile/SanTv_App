import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({
    super.key,
    required this.onProfileTap,
    required this.onLogoutTap,
  });

  /// Se llama cuando el usuario toca "Perfil" en el menú.
  final VoidCallback onProfileTap;

  /// Se llama cuando el usuario toca "Cerrar sesión" en el menú.
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Image.asset(
        'assets/img/original.png',
        height: 63,
        fit: BoxFit.contain,
      ),
      actions: [
        Theme(
          data: Theme.of(context).copyWith(
            popupMenuTheme: const PopupMenuThemeData(
              color: Color(0xFF1E1E1E),
            ),
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white, size: 30),
            offset: const Offset(0, 50),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  onProfileTap();
                  break;
                case 'logout':
                  onLogoutTap();
                  break;
                case 'notifications':
                  // TODO: lógica de notificaciones a futuro
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person_outline, color: Color(0xFF39FF14)),
                  title: Text('Perfil', style: TextStyle(color: Colors.white)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem<String>(
                value: 'notifications',
                child: ListTile(
                  leading: const Icon(Icons.notifications_none, color: Colors.white),
                  title: const Text('Notificaciones', style: TextStyle(color: Colors.white)),
                  trailing: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                    child: const Text(
                      '2',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(height: 1),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.white70),
                  title: Text('Cerrar sesión', style: TextStyle(color: Colors.white70)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}