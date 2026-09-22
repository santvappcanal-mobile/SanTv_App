import 'package:flutter/material.dart';
import 'glass_container.dart';

/// Botón pequeño con efecto glass: ícono + texto.
/// Antes era _buildGlassButton() dentro de profile_screen.dart.
/// Al ser genérico (sin nada específico de "perfil"), vive en common/
/// para poder usarse en cualquier otra pantalla.
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.foregroundColor = Colors.white,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 12,
      blurSigma: 8,
      color: Colors.white.withValues(alpha: 0.06),
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: foregroundColor),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(color: foregroundColor, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}