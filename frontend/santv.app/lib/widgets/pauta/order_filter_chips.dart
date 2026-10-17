import 'package:flutter/material.dart';

/// Filtros del historial: Todas / Pendientes / Validadas / Canceladas.
class OrderFilterChips extends StatelessWidget {
  const OrderFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  static const Color neonGreen = Color(0xFF39FF14);
  static const _filters = {
    'todos': 'Todas',
    'pendiente': 'Pendientes',
    'validado': 'Validadas',
    'cancelado': 'Canceladas',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          for (final e in _filters.entries)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(e.value),
                selected: selected == e.key,
                onSelected: (_) => onSelected(e.key),
                selectedColor: neonGreen,
                backgroundColor: const Color(0xFF1A1A1A),
                side: BorderSide.none,
                labelStyle: TextStyle(
                  color: selected == e.key ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
