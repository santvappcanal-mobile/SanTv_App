import 'package:flutter/material.dart';
import 'custom_text_field.dart';
import 'upload_status_message.dart';

class YoutubeLinkField extends StatelessWidget {
  const YoutubeLinkField({
    super.key,
    required this.controller,
    required this.loading,
    required this.error,
    required this.onSearch,
    this.accentColor = const Color(0xFF39FF14),
  });

  final TextEditingController controller;
  final bool loading;
  final String? error;
  final VoidCallback onSearch;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: controller,
          label: 'Link de YouTube',
          onSubmitted: (_) => onSearch(),
          suffixIcon: IconButton(
            icon: Icon(Icons.search, color: accentColor),
            onPressed: loading ? null : onSearch,
          ),
        ),
        const SizedBox(height: 16),
        if (loading)
          Center(child: CircularProgressIndicator(color: accentColor)),
        if (error != null)
          UploadStatusMessage(
            message: error!,
            isError: true,
            successColor: accentColor,
          ),
      ],
    );
  }
}