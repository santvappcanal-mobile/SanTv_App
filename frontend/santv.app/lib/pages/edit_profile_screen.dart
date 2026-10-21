import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../widgets/profile/avatar_picker_sheet.dart';
import '../widgets/profile/edit_profile_widgets.dart';
import '../widgets/profile/save_profile_button.dart';

/// Pantalla para editar los datos del perfil (por ahora, el nombre).
/// El correo se muestra pero no se puede cambiar.
///
/// [onSaved] se llama con el usuario ya actualizado, para que la pantalla
/// que la abrió (Configuración / Perfil) refresque sus datos.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.authService,
    required this.user,
    required this.onSaved,
  });

  final AuthService authService;
  final AppUser user;
  final void Function(AppUser updated) onSaved;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color background = Color(0xFF0B0B0B);
  static const Color surface = Color(0xFF1A1A1A);

  final _formKey = GlobalKey<FormState>();
  late final EditProfileController _c;

  static const Color _neonGreen = Color(0xFF39FF14);

  @override
  void initState() {
    super.initState();
    _c = EditProfileController(
      authService: widget.authService,
      user: widget.user,
      onSaved: widget.onSaved,
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _openAvatarOptions() {
    showAvatarOptions(
      context,
      hasAvatar: _c.user.avatarUrl != null,
      onGallery: () => _c.pickPhoto(ImageSource.gallery),
      onCamera: () => _c.pickPhoto(ImageSource.camera),
      onAvatar: _c.chooseAvatar,
      onRemove: () => _c.chooseAvatar(''),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final guardado = await _c.save();
    if (guardado && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final inicial = widget.user.name.trim().isNotEmpty
        ? widget.user.name.trim()[0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Editar perfil', style: TextStyle(color: Colors.white)),
      ),
      body: ListenableBuilder(
        listenable: _c,
        builder: (context, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EditableAvatar(
                  avatar: _c.user.avatarUrl,
                  loading: _c.uploadingAvatar,
                  onTap: _openAvatarOptions,
                ),
                const SizedBox(height: 28),
                EditProfileFields(nameCtrl: _c.nameCtrl, emailCtrl: _c.emailCtrl),
                if (_c.error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _c.error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
                const SizedBox(height: 28),
                SaveProfileButton(
                  isLoading: _c.saving,
                  onPressed: _save,
                  backgroundColor: _neonGreen,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoracion(String label, IconData icono) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icono, color: neonGreen),
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: neonGreen),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}