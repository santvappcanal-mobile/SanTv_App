import 'package:flutter/material.dart';

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
      onChanged: (newValue) {
        if (newValue != null) onChanged(newValue);
      },
    );
  }
}