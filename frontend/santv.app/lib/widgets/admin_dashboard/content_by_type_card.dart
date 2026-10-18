import 'package:flutter/material.dart';
import '../../models/admin_stats.dart';
import 'dashboard_style.dart';

class ContentByTypeCard extends StatelessWidget {
  const ContentByTypeCard({super.key, required this.byType});

  final ContentByType byType;

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
          _MiniStat(label: 'Películas', value: byType.movie),
          _MiniStat(label: 'Series', value: byType.series),
          _MiniStat(label: 'Documentales', value: byType.documentary),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            color: kNeonGreen,
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