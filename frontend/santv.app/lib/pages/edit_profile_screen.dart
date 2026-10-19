import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../widgets/profile/avatar_picker_sheet.dart';
import '../widgets/profile/edit_profile_widgets.dart';
import '../widgets/profile/save_profile_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.authService,
    required this.user,
    required this.onSaved,
  });

  final AuthService authService;
  final AppUser user;

  /// Se llama con el usuario ya actualizado, para que Home refresque su estado.
  final ValueChanged<AppUser> onSaved;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
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
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Editar perfil', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
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
}