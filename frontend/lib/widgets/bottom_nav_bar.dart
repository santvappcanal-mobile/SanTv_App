import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home, 'label': 'Inicio'},
      {'icon': Icons.podcasts, 'label': 'En Vivo'},
      {'icon': Icons.play_circle_outline, 'label': 'Videos'},
      {'icon': Icons.article_outlined, 'label': 'Noticias'},
      {'icon': Icons.trending_up, 'label': 'Publicidad'},
    ];

    return Container(
      color: const Color(0xFF141414),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(items.length, (index) {
            final selected = index == currentIndex;
            return GestureDetector(
              onTap: () => onTap(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    items[index]['icon'] as IconData,
                    color: selected ? AppColors.green : Colors.white54,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[index]['label'] as String,
                    style: TextStyle(
                      color: selected ? AppColors.green : Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
