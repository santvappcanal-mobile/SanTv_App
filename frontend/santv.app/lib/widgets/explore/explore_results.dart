import 'package:flutter/material.dart';
import '../../models/content.dart';
import 'explore_card.dart';

/// Título + (spinner | mensaje vacío | cuadrícula de tarjetas).
class ExploreResults extends StatelessWidget {
  const ExploreResults({
    super.key,
    required this.items,
    required this.cargando,
    required this.query,
    required this.savedIds,
    required this.accentColor,
    required this.onToggleSave,
    required this.onTap,
  });

  final List<ContentItem> items;
  final bool cargando;
  final String query;
  final Set<String> savedIds;
  final Color accentColor;
  final ValueChanged<ContentItem> onToggleSave;
  final ValueChanged<ContentItem> onTap;

  static const Color _neon = Color(0xFF39FF14);

  @override
  Widget build(BuildContext context) {
    final buscando = query.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          buscando ? 'Resultados' : 'Contenido para ti',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        if (cargando)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator(color: _neon)),
          )
        else if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                buscando
                    ? 'Sin resultados para "${query.trim()}"'
                    : 'No hay contenido en esta categoría todavía',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return ExploreCard(
                accentColor: accentColor,
                content: item,
                isSaved: savedIds.contains(item.id),
                onToggleSave: () => onToggleSave(item),
                onTap: () => onTap(item),
              );
            },
          ),
      ],
    );
  }
}