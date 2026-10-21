import 'package:flutter/material.dart';
import 'dashboard_style.dart';

class UsersByRoleCard extends StatelessWidget {
  const UsersByRoleCard({super.key, required this.byRole});

  final Map<String, int> byRole;

  @override
  Widget build(BuildContext context) {
    if (byRole.isEmpty) {
      return const Text('Sin datos', style: TextStyle(color: Colors.white54));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: byRole.entries
            .map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: const TextStyle(color: Colors.white70)),
                    Text(
                      '${e.value}',
                      style: const TextStyle(
                        color: kNeonGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}