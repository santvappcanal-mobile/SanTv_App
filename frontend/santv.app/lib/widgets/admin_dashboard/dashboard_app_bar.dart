import 'package:flutter/material.dart';
import 'dashboard_style.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key, required this.onRefresh});

  /// null desactiva el botón (por ejemplo mientras carga).
  final VoidCallback? onRefresh;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: kScreenBg,
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: onRefresh,
        ),
      ],
    );
  }
}