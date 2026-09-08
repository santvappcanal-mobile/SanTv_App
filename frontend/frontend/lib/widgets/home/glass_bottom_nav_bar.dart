import 'package:flutter/material.dart';
import '../common/glass_container.dart';

/// Barra de navegación inferior con efecto glass.
/// Antes era _buildGlassNavBar() dentro de home.dart.
class GlassBottomNavBar extends StatelessWidget {
  const GlassBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.neonColor,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color neonColor;

  static const _items = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
    BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explorar'),
    BottomNavigationBarItem(icon: Icon(Icons.live_tv), label: 'En Vivo'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: GlassContainer(
        borderRadius: 0, // el recorte de esquinas ya lo hace el ClipRRect
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.15))),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: neonColor,
          unselectedItemColor: Colors.white38,
          type: BottomNavigationBarType.fixed,
          items: _items,
        ),
      ),
    );
  }
}