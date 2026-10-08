import 'package:flutter/material.dart';
import '../common/glass_container.dart';

/// Botón de "Cerrar sesión", con su diálogo de confirmación incluido.
class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key, this.onLogout});

  final VoidCallback? onLogout;

  // Cambia solo este color para cambiar todo el estilo.
  // Verde neón: Color(0xFF39FF14) | Rojo: Color(0xFFFF5252)
  static const Color _accent = Color(0xFF39FF14);

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 30,
      blurSigma: 10,
      gradientColors: [
        _accent.withValues(alpha: 0.16),
        _accent.withValues(alpha: 0.04),
      ],
      border: Border.all(color: _accent.withValues(alpha: 0.65), width: 1.2),
      boxShadow: [
        BoxShadow(
          color: _accent.withValues(alpha: 0.18),
          blurRadius: 18,
          spreadRadius: -4,
        ),
      ],
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => _confirmLogout(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: _accent, size: 20),
                SizedBox(width: 10),
                Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: _accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: GlassContainer(
          borderRadius: 28,
          blurSigma: 14,
          color: const Color(0xFF141414).withValues(alpha: 0.92),
          border: Border.all(color: _accent.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: _accent.withValues(alpha: 0.15),
              blurRadius: 30,
              spreadRadius: -4,
            ),
          ],
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _accent.withValues(alpha: 0.12),
                  border: Border.all(color: _accent, width: 1.5),
                ),
                child: const Icon(Icons.logout_rounded, color: _accent, size: 28),
              ),
              const SizedBox(height: 18),
              const Text(
                '¿Cerrar sesión?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tendrás que iniciar sesión de nuevo para acceder a tu cuenta.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        onLogout?.call();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.black,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Salir',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}