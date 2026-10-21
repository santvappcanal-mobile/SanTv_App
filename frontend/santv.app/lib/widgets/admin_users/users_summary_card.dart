import 'package:flutter/material.dart';
import '../admin_dashboard/dashboard_style.dart';

/// Resumen: total, activos e inactivos.
class UsersSummaryCard extends StatelessWidget {
  const UsersSummaryCard({
    super.key,
    required this.total,
    required this.activos,
    required this.inactivos,
  });

  final int total;
  final int activos;
  final int inactivos;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(label: 'Total', value: total, color: Colors.white),
          _SummaryItem(label: 'Activos', value: activos, color: kNeonGreen),
          _SummaryItem(
            label: 'Inactivos',
            value: inactivos,
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}