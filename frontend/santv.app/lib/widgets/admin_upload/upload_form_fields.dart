import 'package:flutter/material.dart';
import '../../models/categories.dart';
import '../admin/content_type_dropdown.dart';
import '../admin/custom_text_field.dart';
import '../admin/video_picker_field.dart';
import '../admin_dashboard/dashboard_style.dart';
import '../common/category_chips.dart';
import 'neon_switch_tile.dart';
import 'upload_form_controller.dart';

class UploadFormFields extends StatelessWidget {
  const UploadFormFields({
    super.key,
    required this.form,
    required this.enabled,
    required this.onPickVideo,
    this.onEdited,
  });

  final UploadFormController form;
  final bool enabled;
  final VoidCallback onPickVideo;

  /// Se llama cuando el usuario cambia categoría o el modo de video.
  final VoidCallback? onEdited;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: form,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: form.titleCtrl,
            label: 'Título',
            requerido: true,
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: form.descriptionCtrl,
            label: 'Descripción',
            requerido: true,
            maxLines: 3,
          ),
          const SizedBox(height: 14),
          ContentTypeDropdown(value: form.type, onChanged: form.setType),
          const SizedBox(height: 18),
          const Text(
            'Categoría',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          CategoryChips(
            categories: kAssignableCategories,
            selected: form.category,
            onSelected: (c) {
              form.setCategory(c);
              onEdited?.call();
            },
          ),
          const SizedBox(height: 18),
          CustomTextField(
            controller: form.thumbnailCtrl,
            label: 'URL de miniatura (opcional)',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: form.durationCtrl,
                  label: 'Duración (min)',
                  tipoNumerico: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: form.yearCtrl,
                  label: 'Año de estreno',
                  tipoNumerico: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          NeonSwitchTile(
            value: form.isPremium,
            onChanged: form.setPremium,
            title: 'Contenido premium',
          ),
          const SizedBox(height: 8),
          NeonSwitchTile(
            value: form.usarUrlExterna,
            onChanged: (v) {
              form.setUsarUrl(v);
              onEdited?.call();
            },
            title: 'Usar URL de video externo',
            subtitle:
                'Actívalo para videos grandes (evita el límite de 100 MB de Cloudinary)',
          ),
          const SizedBox(height: 8),
          if (form.usarUrlExterna)
            CustomTextField(
              controller: form.videoUrlCtrl,
              label: 'URL del video (YouTube, streaming propio, etc.)',
              requerido: true,
            )
          else
            VideoPickerField(
              fileName: form.videoFileName,
              onPick: onPickVideo,
              enabled: enabled,
              accentColor: kNeonGreen,
            ),
        ],
      ),
    );
  }
}