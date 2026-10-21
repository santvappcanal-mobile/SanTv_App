import 'package:flutter/material.dart';
import '../../models/admin_user.dart';
import '../admin_dashboard/dashboard_style.dart';
import 'user_card.dart';
import 'users_summary_card.dart';

/// Resumen + lista de usuarios, con pull-to-refresh.
class UsersBody extends StatelessWidget {
  const UsersBody({super.key, required this.users, required this.onRefresh});

  final List<AdminUser> users;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    // Activo = el usuario está dentro de la app ahora mismo
    final activos = users.where((u) => u.isOnline).length;

    return RefreshIndicator(
      color: kNeonGreen,
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          UsersSummaryCard(
            total: users.length,
            activos: activos,
            inactivos: users.length - activos,
          ),
          const SizedBox(height: 16),
          if (users.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 32),
              child: Center(
                child: Text(
                  'Aún no hay usuarios registrados',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            )
          else
            ...users.map((u) => UserCard(user: u)),
        ],
      ),
    );
  }
}