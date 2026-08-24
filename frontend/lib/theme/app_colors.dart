import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0D0D0D);
  static const cardDark = Color.fromARGB(255, 21, 21, 21);
  static const green = Color(0xFF00E676);
  static const greyText = Color(0xFFB0B0B0);

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2A2A2A),
      Color(0xFF0A0A0A),
    ],
  );
}