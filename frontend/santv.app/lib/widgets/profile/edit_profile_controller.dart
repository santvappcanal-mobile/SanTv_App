import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';

/// Estado y lógica de la pantalla Editar perfil (foto, nombre y correo).
class EditProfileController extends ChangeNotifier {
  EditProfileController({
    required this.authService,
    required AppUser user,
    required this.onSaved,
  }) : user = user,
       nameCtrl = TextEditingController(text: user.name),
       emailCtrl = TextEditingController(text: user.email);

  final AuthService authService;

  /// Se llama con el usuario ya actualizado, para que Home refresque su estado.
  final ValueChanged<AppUser> onSaved;

  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final ImagePicker _picker = ImagePicker();

  AppUser user;
  bool saving = false;
  bool uploadingAvatar = false;
  String? error;
  bool _disposed = false;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  // ───────────────────────── Avatar / foto ─────────────────────────

  Future<void> pickPhoto(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1000,
      imageQuality: 85,
    );
    if (picked == null) return;
    await _updateAvatar(
      () => authService.uploadProfilePhoto(File(picked.path)),
    );
  }

  /// [id] vacío quita el avatar.
  Future<void> chooseAvatar(String id) =>
      _updateAvatar(() => authService.updateProfile(avatarUrl: id));

  Future<void> _updateAvatar(Future<AuthResult> Function() request) async {
    uploadingAvatar = true;
    error = null;
    _notify();

    final result = await request();
    if (_disposed) return;

    uploadingAvatar = false;
    if (result.success && result.user != null) {
      user = result.user!;
      onSaved(user); // refresca Configuración y Home
    } else {
      error = result.errorMessage ?? 'No se pudo actualizar la foto';
    }
    _notify();
  }

  // ───────────────────────── Guardar nombre / correo ─────────────────────────

  /// Devuelve true si se guardó (la pantalla debe cerrarse).
  Future<bool> save() async {
    saving = true;
    error = null;
    _notify();

    final result = await authService.updateProfile(
      name: nameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
    );
    if (_disposed) return false;

    saving = false;
    final ok = result.success && result.user != null;
    if (ok) {
      user = result.user!;
      onSaved(user);
    } else {
      error = result.errorMessage ?? 'No se pudo guardar';
    }
    _notify();
    return ok;
  }

  @override
  void dispose() {
    _disposed = true;
    nameCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }
}