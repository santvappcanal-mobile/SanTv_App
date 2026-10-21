import 'package:flutter/material.dart';
import '../../models/admin_user.dart';
import '../admin_dashboard/dashboard_style.dart';
import 'user_status_chip.dart';

String _formatearFecha(DateTime? fecha) {
  if (fecha == null) return '';
  final f = fecha.toLocal();
  final dia = f.day.toString().padLeft(2, '0');
  final mes = f.month.toString().padLeft(2, '0');
  return '$dia/$mes/${f.year}';
}

class UserCard extends StatelessWidget {
  const UserCard({super.key, required this.user});

  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    final inicial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';
    final fecha = _formatearFecha(user.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white12,
            child: Text(
              inicial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    user.role,
                    if (!user.isVerified) 'sin verificar',
                    if (fecha.isNotEmpty) 'desde $fecha',
                  ].join(' · '),
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          UserStatusChip(activo: user.isOnline),
        ],
      ),
    );
  }
}