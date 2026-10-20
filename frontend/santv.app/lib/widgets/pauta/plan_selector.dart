import 'package:flutter/material.dart';
import '../../models/ad_plan.dart';

/// Lista de planes seleccionables (uno a la vez).
class PlanSelector extends StatelessWidget {
  const PlanSelector({
    super.key,
    required this.plans,
    required this.selected,
    required this.onChanged,
  });

  final List<AdPlan> plans;
  final AdPlan selected;
  final ValueChanged<AdPlan> onChanged;

  static const Color neonGreen = Color(0xFF39FF14);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final plan in plans)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onChanged(plan),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: plan == selected ? neonGreen : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      plan == selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: plan == selected ? neonGreen : Colors.white38,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            plan.description,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatCop(plan.price),
                      style: const TextStyle(
                        color: neonGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
