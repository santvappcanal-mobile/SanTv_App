import 'package:flutter/material.dart';
import '../admin_dashboard/dashboard_style.dart';

class NeonSwitchTile extends StatelessWidget {
  const NeonSwitchTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.subtitle,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: kNeonGreen,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
      contentPadding: EdgeInsets.zero,
    );
  }
}