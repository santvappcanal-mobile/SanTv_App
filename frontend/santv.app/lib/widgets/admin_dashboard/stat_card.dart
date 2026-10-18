import 'package:flutter/material.dart';
import 'dashboard_style.dart';

class StatCardData {
  const StatCardData(
    this.label,
    this.value,
    this.icon, {
    this.subtitle = '',
    this.onTap,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
}

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.data});

  final StatCardData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kCardBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: data.onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(data.icon, color: kNeonGreen, size: 22),
                  if (data.onTap != null)
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.white38,
                      size: 20,
                    ),
                ],
              ),
              const Spacer(),
              Text(
                data.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                data.label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              if (data.subtitle.isNotEmpty)
                Text(
                  data.subtitle,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
            ],
          ),
        ),
      ),
    );
  }
}