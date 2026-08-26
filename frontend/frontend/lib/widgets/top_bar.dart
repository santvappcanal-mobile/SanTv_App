// Archivo: lib/widgets/top_bar.dart
import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({super.key});

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
        // Menú hamburguesa desplegable
        Theme(
          // Envolvemos en un Theme para personalizar el color de fondo del menú
          data: Theme.of(context).copyWith(
            popupMenuTheme: const PopupMenuThemeData(
              color: Color(0xFF1E1E1E), // Color de fondo oscuro para el menú
            ),
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white, size: 30),
            offset: const Offset(0, 50), // Desplaza el menú un poco hacia abajo
            onSelected: (value) {
              // Manejo de la navegación según la opción seleccionada
              switch (value) {
                case 'register':
                  // Te lleva a '/login' porque ahí está tu AuthScreen
                  // que contiene el formulario de registro y login.
                  Navigator.pushNamed(context, '/login');
                  break;
                case 'logout':
                  Navigator.pushReplacementNamed(context, '/login');
                  break;
                case 'notifications':
                  // Aquí puedes agregar la lógica para las notificaciones en el futuro
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'register',
                child: ListTile(
                  leading: Icon(Icons.person_outline, color: Color(0xFF39FF14)),
                  title: Text(
                    'Perfil', 
                    style: TextStyle(color: Colors.white),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem<String>(
                value: 'notifications',
                child: ListTile(
                  leading: const Icon(Icons.notifications_none, color: Colors.white),
                  title: const Text(
                    'Notificaciones', 
                    style: TextStyle(color: Colors.white),
                  ),
                  // Indicador rojo de notificaciones
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
              const PopupMenuDivider(height: 1), // Línea divisoria entre opciones
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.white70),
                  title: Text(
                    'Cerrar sesión', 
                    style: TextStyle(color: Colors.white70),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8), // Pequeño margen a la derecha
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}