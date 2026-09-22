import 'package:flutter/material.dart';

class UploadStatusMessage extends StatelessWidget {
  const UploadStatusMessage({
    super.key,
    required this.message,
    required this.isError,
    required this.successColor,
  });

  final String message;
  final bool isError;
  final Color successColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        message,
        style: TextStyle(
          color: isError ? Colors.redAccent : successColor,
        ),
      ),
    );
  }
}