import 'package:flutter/material.dart';
import '../admin/upload_status_message.dart';
import '../admin/upload_submit_button.dart';
import '../admin_dashboard/dashboard_style.dart';

/// Mensaje de estado (si hay) + botón de enviar.
class UploadSubmitSection extends StatelessWidget {
  const UploadSubmitSection({
    super.key,
    required this.message,
    required this.isError,
    required this.isLoading,
    required this.onPressed,
  });

  final String? message;
  final bool isError;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        if (message != null)
          UploadStatusMessage(
            message: message!,
            isError: isError,
            successColor: kNeonGreen,
          ),
        UploadSubmitButton(
          isLoading: isLoading,
          onPressed: onPressed,
          backgroundColor: kNeonGreen,
        ),
      ],
    );
  }
}