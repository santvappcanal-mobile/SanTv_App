import 'package:flutter/material.dart';

import '../../pages/admin_reports_screen.dart';
import '../../pages/my_reports_screen.dart';
import '../../pages/news_map_screen.dart';
import '../../pages/report_create_screen.dart';
import '../../services/auth_service.dart';

/// Tarjeta del Home con todos los accesos del Reportero Ciudadano.
/// Se muestra igual para usuarios y admins; los admins/editores ven
/// además el botón para revisar los reportes pendientes.
class CitizenReporterCard extends StatelessWidget {
  const CitizenReporterCard({
    super.key,
    required this.authService,
    this.isAdmin = false,
  });

  final AuthService authService;
  final bool isAdmin;

  static const _neon = Color(0xFF39FF14);

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _neon.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.campaign, color: _neon, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Reportero SAN TV',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '¿Viste algo en tu comunidad? Toma una foto, cuéntanos y sal en las noticias.',
            style: TextStyle(color: Colors.white70, height: 1.35),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _open(context, ReportCreateScreen(authService: authService)),
              icon: const Icon(Icons.photo_camera),
              label: const Text('Reportar ahora',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _neon,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SecondaryButton(
                  icon: Icons.map_outlined,
                  label: 'Mapa de noticias',
                  onTap: () => _open(context, NewsMapScreen(authService: authService)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SecondaryButton(
                  icon: Icons.history,
                  label: 'Mis reportes',
                  onTap: () => _open(context, MyReportsScreen(authService: authService)),
                ),
              ),
            ],
          ),
          if (isAdmin) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: _SecondaryButton(
                icon: Icons.fact_check_outlined,
                label: 'Revisar reportes pendientes',
                onTap: () => _open(context, AdminReportsScreen(authService: authService)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white24),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}