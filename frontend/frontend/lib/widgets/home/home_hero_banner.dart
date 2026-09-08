import 'package:flutter/material.dart';
import '../common/glass_container.dart';

/// Banner superior de la pestaña de inicio ("Canal en vivo").
/// Antes vivía inline dentro de _buildHomeTab() en home.dart.
class HomeHeroBanner extends StatelessWidget {
  const HomeHeroBanner({super.key, required this.neonColor});

  final Color neonColor;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      height: 200,
      width: double.infinity,
      gradientColors: [
        neonColor.withValues(alpha: 0.20),
        Colors.white.withValues(alpha: 0.05),
      ],
      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      boxShadow: [
        BoxShadow(
          color: neonColor.withValues(alpha: 0.15),
          blurRadius: 30,
          spreadRadius: -8,
        ),
      ],
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
    );
  }
}