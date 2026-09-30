import 'package:flutter/material.dart';

/// Botones (chips) para elegir UNA categoría.
/// Se usa en los formularios del admin. Se acomodan en varias
/// líneas si no caben en el ancho de la pantalla.
class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String? selected;
  final ValueChanged<String> onSelected;

  static const Color neonGreen = Color(0xFF39FF14);
  static const Color cardBg = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final isSelected = cat == selected;
        return ChoiceChip(
          label: Text(cat),
          selected: isSelected,
          onSelected: (_) => onSelected(cat),
          selectedColor: neonGreen,
          backgroundColor: cardBg,
          labelStyle: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide.none,
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}