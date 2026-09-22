import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({
    super.key,
    required this.onNotificationsTap,
    this.unreadCount = 0,
  });

  /// Se llama cuando el usuario toca la campana de notificaciones.
  final VoidCallback onNotificationsTap;

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
        IconButton(
          onPressed: onNotificationsTap,
          tooltip: 'Notificaciones',
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_none,
                color: Colors.white,
                size: 30,
              ),
              if (unreadCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
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