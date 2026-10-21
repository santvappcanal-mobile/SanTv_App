import 'package:flutter/material.dart';
import '../../models/categories.dart';
import '../publicidad_section.dart';
import 'category_chips_row.dart';
import 'explore_search_bar.dart';

/// Parte de arriba de Explorar: buscador, categorías y publicidad.
class ExploreHeader extends StatelessWidget {
  const ExploreHeader({
    super.key,
    required this.accentColor,
    required this.selectedCategory,
    required this.onQueryChanged,
    required this.onCategorySelected,
    required this.onOpenAdvertising,
  });

  final Color accentColor;
  final int selectedCategory;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<int> onCategorySelected;
  final VoidCallback onOpenAdvertising;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExploreSearchBar(accentColor: accentColor, onChanged: onQueryChanged),
        const SizedBox(height: 20),
        CategoryChipsRow(
          categories: kCategories,
          selectedIndex: selectedCategory,
          onSelected: onCategorySelected,
          accentColor: accentColor,
        ),
        const SizedBox(height: 20),
        PublicidadSection(onTap: onOpenAdvertising),
        const SizedBox(height: 24),
      ],
    );
  }
}