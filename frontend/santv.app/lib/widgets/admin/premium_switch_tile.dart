import 'package:flutter/material.dart';

class PremiumSwitchTile extends StatelessWidget {
  const PremiumSwitchTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: activeColor,
      contentPadding: EdgeInsets.zero,
      title: const Text(
        'Contenido premium',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}