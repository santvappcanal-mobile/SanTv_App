import 'package:flutter/material.dart';

class ForgotPasswordLink extends StatelessWidget {
  const ForgotPasswordLink({
    super.key,
    required this.onTap,
    required this.accentColor,
  });

  final VoidCallback? onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(
            color: accentColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}