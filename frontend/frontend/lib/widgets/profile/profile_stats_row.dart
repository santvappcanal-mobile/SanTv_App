import 'package:flutter/material.dart';
import '../common/glass_container.dart';

/// Fila de estadísticas del perfil (Favoritos y Vistos).
/// Antes era _buildStatsRow() dentro de profile_screen.dart.
///
/// Nota: "Siguiendo" se eliminó por decisión del proyecto. Favoritos
/// y Vistos quedan fijos en 0 hasta implementar el conteo real.
class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({super.key});

  static const Color _neonGreen = Color(0xFF39FF14);

  static const _stats = [
    {'label': 'Favoritos', 'value': '0'},
    {'label': 'Vistos', 'value': '0'},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _stats.map((s) {
        final isLast = s == _stats.last;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 10),
            child: GlassContainer(
              borderRadius: 16,
              blurSigma: 10,
              color: Colors.white.withOpacity(0.06),
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                children: [
                  Text(
                    s['value']!,
                    style: const TextStyle(
                      color: _neonGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s['label']!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}