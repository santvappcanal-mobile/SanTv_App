import 'package:flutter/material.dart';

class AdPopupCloseButton extends StatelessWidget {
  const AdPopupCloseButton({
    super.key,
    required this.onTap,
    this.accentColor = const Color(0xFF39FF14),
  });

  final VoidCallback onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
        child: const Icon(Icons.close, color: Colors.black, size: 20),
      ),
    );
  }
}