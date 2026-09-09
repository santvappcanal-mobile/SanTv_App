import 'package:flutter/material.dart';
import '../widgets/publicidad_section.dart';
import '../widgets/explore/explore_search_bar.dart';
import '../widgets/explore/category_chips_row.dart';
import '../widgets/explore/explore_card.dart';

/// Pestaña "Explorar". Se usa embebida dentro de [Home]
/// (pages/home.dart), como uno de los ítems del IndexedStack.
/// Toda la lógica de búsqueda y categorías vive aquí, separada
/// del resto de las pestañas.
///
/// La navegación a Publicidad se resuelve arriba, en Home
/// (necesita el token/rol del usuario), por eso llega acá como
/// callback en lugar de resolverse dentro de este widget.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, required this.onOpenAdvertising});

  final VoidCallback onOpenAdvertising;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _selectedCategory = 0;

  final List<String> _categories = const [
    'Todo',
    'Deportes',
    'Noticias',
    'Música',
    'Gaming',
    'Educación',
  ];

  @override
  Widget build(BuildContext context) {
    final neonColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExploreSearchBar(accentColor: neonColor),
          const SizedBox(height: 20),
          CategoryChipsRow(
            categories: _categories,
            selectedIndex: _selectedCategory,
            onSelected: (index) => setState(() => _selectedCategory = index),
            accentColor: neonColor,
          ),
          const SizedBox(height: 20),

          // Sección de Publicidad (tarjeta clicable, no FAB)
          PublicidadSection(onTap: widget.onOpenAdvertising),
          const SizedBox(height: 24),

          const Text(
            'Contenido para ti',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),

          // Grilla de contenido en tarjetas de vidrio
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 8,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              return ExploreCard(accentColor: neonColor, index: index);
            },
          ),
        ],
      ),
    );
  }
}
