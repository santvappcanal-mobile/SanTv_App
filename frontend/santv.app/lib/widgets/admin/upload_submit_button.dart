import 'package:flutter/material.dart';

class UploadSubmitButton extends StatelessWidget {
  const UploadSubmitButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.backgroundColor,
    this.label = 'Subir contenido',
  });

  final bool isLoading;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}