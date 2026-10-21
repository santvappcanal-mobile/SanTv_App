import 'package:flutter/material.dart';
import 'package:santv_app/models/content.dart';
import 'package:santv_app/widgets/explore/explore_card.dart';

/// Sección "Más transmisiones": videos que el admin marcó con
/// "Mostrar en la pestaña En vivo". Muestra un spinner mientras carga
/// y no ocupa espacio si no hay videos.
class LiveMoreStreams extends StatelessWidget {
  const LiveMoreStreams({
    super.key,
    required this.cargando,
    required this.items,
    required this.savedIds,
    required this.accentColor,
    required this.onToggleSave,
    required this.onTap,
  });

  final bool cargando;
  final List<ContentItem> items;
  final Set<String> savedIds;
  final Color accentColor;
  final ValueChanged<ContentItem> onToggleSave;
  final ValueChanged<ContentItem> onTap;

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF39FF14)),
        ),
      );
    }
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Más transmisiones',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
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