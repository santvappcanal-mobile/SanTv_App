import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({
    super.key,
    required this.onNotificationsTap,
    required this.onProfileTap,
    required this.onLogoutTap,
    this.unreadCount = 0,
  });

  /// Se llama cuando el usuario toca "Notificaciones" en el menú.
  final VoidCallback onNotificationsTap;

  /// Se llama cuando el usuario toca "Perfil" en el menú.
  final VoidCallback onProfileTap;

  /// Se llama cuando el usuario toca "Cerrar sesión" en el menú.
  final VoidCallback onLogoutTap;

  /// Cantidad de notificaciones sin leer (para el badge rojo).
  final int unreadCount;

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
                case 'notifications':
                  onNotificationsTap();
                  break;
                case 'profile':
                  onProfileTap();
                  break;
                case 'logout':
                  onLogoutTap();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'notifications',
                child: ListTile(
                  leading: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Notificaciones',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: unreadCount > 0
                      ? Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : null,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person_outline, color: Colors.white),
                  title: Text('Perfil', style: TextStyle(color: Colors.white)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.redAccent),
                  title: Text(
                    'Cerrar sesión',
                    style: TextStyle(color: Colors.redAccent),
                  ),
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