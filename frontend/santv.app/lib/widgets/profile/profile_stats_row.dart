import 'package:flutter/material.dart';
import '../common/glass_container.dart';

/// Fila de estadísticas del perfil (Favoritos y Vistos).
///
/// Nota: "Siguiendo" se eliminó por decisión del proyecto.
/// Los valores llegan desde ProfileScreen (conteo real del backend).
class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({super.key, this.favorites = 0, this.watched = 0});

  /// Videos guardados en Mi Lista.
  final int favorites;

  /// Videos distintos que el usuario ha visto.
  final int watched;

  static const Color _neonGreen = Color(0xFF39FF14);

  @override
  Widget build(BuildContext context) {
    final stats = [
      {'label': 'Favoritos', 'value': '$favorites'},
      {'label': 'Vistos', 'value': '$watched'},
    ];

    return Row(
      children: [
        for (var i = 0; i < stats.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == stats.length - 1 ? 0 : 10),
              child: GlassContainer(
                borderRadius: 16,
                blurSigma: 10,
                color: Colors.white.withValues(alpha: 0.06),
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  children: [
                    Text(
                      stats[i]['value']!,
                      style: const TextStyle(
                        color: _neonGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stats[i]['label']!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}