import 'package:flutter/material.dart';

/// Fondo con degradado oscuro/verde del Home.
class HomeGradientBackground extends StatelessWidget {
  const HomeGradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B0B0B), Color(0xFF10241A), Color(0xFF0B0B0B)],
        ),
      ),
      child: child,
    );
  }
}