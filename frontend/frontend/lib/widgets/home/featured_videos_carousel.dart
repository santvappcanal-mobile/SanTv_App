import 'package:flutter/material.dart';
import '../common/glass_container.dart';

/// Sección "Videos destacados": título + carrusel horizontal.
/// Antes era el ListView.builder inline al final de _buildHomeTab().
class FeaturedVideosCarousel extends StatelessWidget {
  const FeaturedVideosCarousel({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Videos destacados',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            itemBuilder: (context, index) => const Padding(
              padding: EdgeInsets.only(right: 12),
              child: _VideoPlaceholderCard(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Tarjeta individual del carrusel. Privada porque, por ahora,
/// solo la usa FeaturedVideosCarousel.
class _VideoPlaceholderCard extends StatelessWidget {
  const _VideoPlaceholderCard();

  @override
  Widget build(BuildContext context) {
    return const GlassContainer(
      width: 140,
      blurSigma: 10,
      child: Center(
        child: Text(
          'Agregar Video',
          style: TextStyle(color: Color.fromARGB(255, 243, 239, 239)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}