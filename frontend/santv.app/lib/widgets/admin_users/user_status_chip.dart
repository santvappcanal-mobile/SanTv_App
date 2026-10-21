import 'package:flutter/material.dart';
import '../admin_dashboard/dashboard_style.dart';

/// Chip "Activo" / "Inactivo" de cada usuario.
class UserStatusChip extends StatelessWidget {
  const UserStatusChip({super.key, required this.activo});

  final bool activo;

  @override
  Widget build(BuildContext context) {
    final color = activo ? kNeonGreen : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 8),
          const SizedBox(width: 6),
          Text(
            activo ? 'Activo' : 'Inactivo',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}