import 'dart:ui';
import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onTap,
    required this.enabled,
    this.label = 'Continuar con Google',
  });

  final VoidCallback onTap;
  final bool enabled;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.06),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: enabled ? onTap : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.g_mobiledata_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
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