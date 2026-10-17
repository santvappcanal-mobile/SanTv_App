import 'package:flutter/material.dart';
import '../../models/categories.dart';
import '../../services/content_services.dart';
import '../common/category_chips.dart';
import 'content_type_dropdown.dart';
import 'custom_text_field.dart';
import 'premium_switch_tile.dart';
import 'upload_submit_button.dart';
import 'youtube_preview_card.dart';

class YoutubeVideoForm extends StatelessWidget {
  const YoutubeVideoForm({
    super.key,
    required this.preview,
    required this.descriptionController,
    required this.yearController,
    required this.type,
    required this.category,
    required this.isPremium,
    required this.saving,
    required this.onTypeChanged,
    required this.onCategoryChanged,
    required this.onPremiumChanged,
    required this.onSubmit,
    this.accentColor = const Color(0xFF39FF14),
  });

  final YoutubePreviewResult preview;
  final TextEditingController descriptionController;
  final TextEditingController yearController;
  final String type;
  final String? category;
  final bool isPremium;
  final bool saving;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<bool> onPremiumChanged;
  final VoidCallback onSubmit;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        YoutubePreviewCard(
          thumbnailUrl: preview.thumbnailUrl,
          title: preview.title,
          channelName: preview.channelName,
        ),
        const SizedBox(height: 20),
        ContentTypeDropdown(value: type, onChanged: onTypeChanged),
        const SizedBox(height: 14),
        CustomTextField(
          controller: descriptionController,
          label: 'Descripción',
          maxLines: 3,
        ),
        const SizedBox(height: 18),
        const Text(
          'Categoría',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        CategoryChips(
          categories: kAssignableCategories,
          selected: category,
          onSelected: onCategoryChanged,
        ),
        const SizedBox(height: 18),
        CustomTextField(
          controller: yearController,
          label: 'Año de estreno',
          tipoNumerico: true,
        ),
        const SizedBox(height: 8),
        PremiumSwitchTile(
          value: isPremium,
          onChanged: onPremiumChanged,
          activeColor: accentColor,
        ),
        const SizedBox(height: 24),
        UploadSubmitButton(
          isLoading: saving,
          onPressed: onSubmit,
          backgroundColor: accentColor,
          label: 'Agregar video',
        ),
      ],
    );
  }
}