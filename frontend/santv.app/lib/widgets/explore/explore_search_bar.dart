import 'dart:ui';
import 'package:flutter/material.dart';

class ExploreSearchBar extends StatelessWidget {
  const ExploreSearchBar({super.key, required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Buscar canales, videos, streamers...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
              prefixIcon: Icon(Icons.search, color: accentColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
    );
  }
}