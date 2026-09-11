import 'package:flutter/material.dart';

/// Botón "CONFIRMAR CÓDIGO", con estado de carga.
class VerifyButton extends StatelessWidget {
  const VerifyButton({
    super.key,
    required this.loading,
    required this.onPressed,
    this.accentColor = const Color(0xFF39FF14),
  });

  final bool loading;
  final VoidCallback? onPressed;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
      ),
      child: loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black,
              ),
            )
          : const Text(
              'CONFIRMAR CÓDIGO',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
    );
  }
}