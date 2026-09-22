import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Image.asset(
            'assets/img/original.png',
            height: 110,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tu plataforma de streaming favorita',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}