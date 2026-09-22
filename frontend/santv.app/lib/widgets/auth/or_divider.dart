import 'package:flutter/material.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: Colors.white.withValues(alpha: 0.2)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'O',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          ),
        ),
        Expanded(
          child: Divider(color: Colors.white.withValues(alpha: 0.2)),
        ),
      ],
    );
  }
}