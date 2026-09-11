import 'dart:ui';
import 'package:flutter/material.dart';
import 'live_tab_badge.dart';

/// Tarjeta grande de la transmisión más vista, arriba de la grilla
/// en LiveTabScreen.
class FeaturedLiveCard extends StatelessWidget {
  const FeaturedLiveCard({
    super.key,
    required this.title,
    required this.streamer,
    required this.viewers,
    required this.neonColor,
    required this.onTap,
  });

  final String title;
  final String streamer;
  final int viewers;
  final Color neonColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                neonColor.withOpacity(0.22),
                Colors.white.withOpacity(0.05),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
            boxShadow: [
              BoxShadow(
                color: neonColor.withOpacity(0.15),
                blurRadius: 30,
                spreadRadius: -8,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const LiveTabBadge(),
                        const Spacer(),
                        Icon(
                          Icons.visibility,
                          size: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$viewers viendo',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        size: 56,
                        color: neonColor,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      streamer,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}