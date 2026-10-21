import 'package:flutter/material.dart';
import 'pulsing_live_dot.dart';

/// Título "Canal en vivo" con el punto parpadeante.
class LiveChannelHeader extends StatelessWidget {
  const LiveChannelHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        PulsingLiveDot(),
        SizedBox(width: 8),
        Text(
          'Canal en vivo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}