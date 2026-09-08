import 'package:flutter/material.dart';

const Color _neonGreen = Color(0xFF39FF14);

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.requerido = false,
    this.tipoNumerico = false,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final bool requerido;
  final bool tipoNumerico;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: tipoNumerico ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF141414),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: requerido
          ? (value) =>
              (value == null || value.trim().isEmpty) ? 'Campo obligatorio' : null
          : null,
    );
  }
}

class ContentTypeDropdown extends StatelessWidget {
  const ContentTypeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: const Color(0xFF141414),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Tipo de contenido',
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF141414),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'movie', child: Text('Película')),
        DropdownMenuItem(value: 'series', child: Text('Serie')),
        DropdownMenuItem(value: 'documentary', child: Text('Documental')),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class VideoPickerField extends StatelessWidget {
  const VideoPickerField({
    super.key,
    required this.fileName,
    required this.onPick,
    this.disabled = false,
  });

  final String? fileName;
  final VoidCallback onPick;
  final bool disabled;

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
          const Icon(Icons.video_file_outlined, color: _neonGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName ?? 'Ningún video seleccionado',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: disabled ? null : onPick,
            child: const Text('Elegir video'),
          ),
        ],
      ),
    );
  }
}