import 'package:flutter/material.dart';

/// Botón circular semitransparente (salir/ampliar pantalla completa).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 38,
    this.alpha = 0.55,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: alpha),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}