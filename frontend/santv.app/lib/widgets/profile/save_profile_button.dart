import 'package:flutter/material.dart';

class SaveProfileButton extends StatelessWidget {
  const SaveProfileButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.backgroundColor,
  });

  final bool isLoading;
  final VoidCallback onPressed;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
            )
          : const Text(
              'Guardar cambios',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
    );
  }
}