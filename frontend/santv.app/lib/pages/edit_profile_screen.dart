import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../widgets/profile/avatar_picker_sheet.dart';
import '../widgets/profile/profile_avatar.dart';
import '../widgets/profile/profile_form_field.dart';
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
  final _picker = ImagePicker();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late AppUser _user;

  bool _saving = false;
  bool _uploadingAvatar = false;
  String? _error;

  static const Color _neonGreen = Color(0xFF39FF14);

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _nameCtrl = TextEditingController(text: widget.user.name);
    _emailCtrl = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  // ───────────────────────── Avatar / foto ─────────────────────────

  void _openAvatarOptions() {
    showAvatarOptions(
      context,
      hasAvatar: _user.avatarUrl != null,
      onGallery: () => _pickPhoto(ImageSource.gallery),
      onCamera: () => _pickPhoto(ImageSource.camera),
      onAvatar: _chooseAvatar,
      onRemove: () => _chooseAvatar(''),
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1000,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() {
      _uploadingAvatar = true;
      _error = null;
    });
    final result =
        await widget.authService.uploadProfilePhoto(File(picked.path));
    _handleAvatarResult(result);
  }

  Future<void> _chooseAvatar(String id) async {
    setState(() {
      _uploadingAvatar = true;
      _error = null;
    });
    final result = await widget.authService.updateProfile(avatarUrl: id);
    _handleAvatarResult(result);
  }

  void _handleAvatarResult(AuthResult result) {
    if (!mounted) return;
    setState(() => _uploadingAvatar = false);

    if (result.success && result.user != null) {
      setState(() => _user = result.user!);
      widget.onSaved(result.user!); // refresca Configuración y Home
    } else {
      setState(
        () => _error = result.errorMessage ?? 'No se pudo actualizar la foto',
      );
    }
  }

  // ───────────────────────── Guardar nombre / correo ─────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    final result = await widget.authService.updateProfile(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
    );

    if (!mounted) return;

    setState(() => _saving = false);

    if (result.success && result.user != null) {
      widget.onSaved(result.user!);
      Navigator.pop(context);
    } else {
      setState(() => _error = result.errorMessage ?? 'No se pudo guardar');
    }
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _uploadingAvatar ? null : _openAvatarOptions,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _neonGreen, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: _neonGreen.withValues(alpha: 0.4),
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ProfileAvatar(
                          avatar: _user.avatarUrl,
                          radius: 52,
                        ),
                      ),
                      if (_uploadingAvatar)
                        const CircularProgressIndicator(color: _neonGreen),
                      const Positioned(
                        bottom: 2,
                        right: 2,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: _neonGreen,
                          child: Icon(Icons.edit, size: 16, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              ProfileFormField(
                controller: _nameCtrl,
                label: 'Nombre',
                accentColor: _neonGreen,
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'El nombre es obligatorio';
                  final nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
                  if (!nameRegex.hasMatch(v)) return 'El nombre solo puede contener letras';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ProfileFormField(
                controller: _emailCtrl,
                label: 'Correo',
                accentColor: _neonGreen,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'El correo es obligatorio';
                  if (!v.contains('@')) return 'Correo inválido';
                  return null;
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 28),
              SaveProfileButton(
                isLoading: _saving,
                onPressed: _save,
                backgroundColor: _neonGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}