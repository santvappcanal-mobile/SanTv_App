import 'package:flutter/material.dart';

/// Punto rojo que parpadea suavemente (fade in/out), usado en el
/// encabezado "En vivo ahora" de LiveTabScreen.
class PulsingLiveDot extends StatefulWidget {
  const PulsingLiveDot({super.key});

  @override
  State<PulsingLiveDot> createState() => _PulsingLiveDotState();
}

class _PulsingLiveDotState extends State<PulsingLiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.4, end: 1.0).animate(_controller),
      child: const Icon(Icons.circle, color: Colors.red, size: 12),
    );
  }
}