import 'package:flutter/material.dart';

class VideoPickerField extends StatelessWidget {
  const VideoPickerField({
    super.key,
    required this.fileName,
    required this.onPick,
    required this.enabled,
    required this.accentColor,
  });

  final String? fileName;
  final VoidCallback onPick;
  final bool enabled;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(Icons.video_file_outlined, color: accentColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName ?? 'Ningún video seleccionado',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: enabled ? onPick : null,
            child: const Text('Elegir video'),
          ),
        ],
      ),
    );
  }
}