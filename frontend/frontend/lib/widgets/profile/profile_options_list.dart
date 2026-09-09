import 'package:flutter/material.dart';
import '../common/glass_container.dart';

/// Una opción dentro de la tarjeta de cuenta (ej. "Mi Lista", "Publicidad").
class ProfileMenuOption {
  const ProfileMenuOption({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
}

/// Tarjeta con la lista de opciones de cuenta.
/// Antes era _buildOptionsCard() (+ la clase privada _ProfileOption)
/// dentro de profile_screen.dart.
class ProfileOptionsList extends StatelessWidget {
  const ProfileOptionsList({super.key, required this.options});

  final List<ProfileMenuOption> options;

  static const Color _neonGreen = Color(0xFF39FF14);

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 18,
      blurSigma: 12,
      color: Colors.white.withOpacity(0.05),
      padding: EdgeInsets.zero,
      child: Column(
        children: List.generate(options.length, (index) {
          final option = options[index];
          final isLast = index == options.length - 1;
          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: option.onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Icon(option.icon, color: _neonGreen, size: 20),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            option.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: Colors.white.withOpacity(0.08),
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }),
      ),
    );
  }
}