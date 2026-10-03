import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.authService,
    required this.user,
    required this.onUserUpdated,
    required this.onLogout,
  });

  final AuthService authService;
  final AppUser user;

  /// Se llama cuando el usuario edita su perfil, para refrescar Home.
  final ValueChanged<AppUser> onUserUpdated;

  /// Cierra la sesión (usa el _handleLogout de Home).
  final Future<void> Function() onLogout;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color _neonGreen = Color(0xFF39FF14);
  static const Color _background = Color(0xFF0B0B0B);
  static const Color _card = Color(0xFF1A1A1A);

  bool _autoplay = true;
  int _scaleIndex = SettingsService.textScaleIndex;
  late AppUser _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    SettingsService.getAutoplay().then((v) {
      if (mounted) setState(() => _autoplay = v);
    });
  }

  Future<void> _clearCache() async {
    await DefaultCacheManager().emptyCache();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Caché limpiada')),
    );
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _card,
        title: const Text('Cerrar sesión',
            style: TextStyle(color: Colors.white)),
        content: const Text('¿Seguro que quieres salir?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salir',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await widget.onLogout();
  }

  Widget _section(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: _neonGreen,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _navTile(
    IconData icon,
    String title, {
    String? subtitle,
    VoidCallback? onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? _neonGreen),
      title: Text(title, style: TextStyle(color: color ?? Colors.white)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle, style: const TextStyle(color: Colors.white54)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Configuración',
            style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('Cuenta', [
            _navTile(
              Icons.person_outline,
              'Editar perfil',
              subtitle: _user.email,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(
                      authService: widget.authService,
                      user: _user,
                      onSaved: (updated) {
                        setState(() => _user = updated);
                        widget.onUserUpdated(updated);
                      },
                    ),
                  ),
                );
              },
            ),
            _navTile(
              Icons.logout,
              'Cerrar sesión',
              color: Colors.redAccent,
              onTap: _confirmLogout,
            ),
          ]),
          _section('Apariencia', [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.text_fields, color: _neonGreen),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Tamaño de letra',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      Text(
                        SettingsService.textScaleLabels[_scaleIndex],
                        style: const TextStyle(color: _neonGreen),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('A',
                          style: TextStyle(color: Colors.white54, fontSize: 12)),
                      Expanded(
                        child: Slider(
                          value: _scaleIndex.toDouble(),
                          min: 0,
                          max: (SettingsService.textScaleSteps.length - 1)
                              .toDouble(),
                          divisions: SettingsService.textScaleSteps.length - 1,
                          activeColor: _neonGreen,
                          inactiveColor: Colors.white24,
                          // Mientras arrastras solo se mueve el control y la
                          // vista previa; la app se reescala al soltar.
                          onChanged: (v) =>
                              setState(() => _scaleIndex = v.round()),
                          onChangeEnd: (v) =>
                              SettingsService.setTextScaleIndex(v.round()),
                        ),
                      ),
                      const Text('A',
                          style: TextStyle(color: Colors.white54, fontSize: 24)),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Así se verá el texto en SAN TV',
                      textScaler: TextScaler.linear(
                        SettingsService.textScaleSteps[_scaleIndex],
                      ),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ]),
          _section('Reproducción', [
            SwitchListTile(
              secondary:
                  const Icon(Icons.play_circle_outline, color: _neonGreen),
              title: const Text('Reproducción automática',
                  style: TextStyle(color: Colors.white)),
              subtitle: const Text('El video inicia al abrirlo',
                  style: TextStyle(color: Colors.white54)),
              value: _autoplay,
              activeColor: _neonGreen,
              onChanged: (v) {
                setState(() => _autoplay = v);
                SettingsService.setAutoplay(v);
              },
            ),
          ]),
          _section('Almacenamiento', [
            _navTile(
              Icons.cleaning_services_outlined,
              'Limpiar caché',
              subtitle: 'Borra las imágenes guardadas en el teléfono',
              onTap: _clearCache,
            ),
          ]),
          _section('Acerca de', [
            _navTile(
              Icons.info_outline,
              'Versión de la app',
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'SAN TV',
                applicationVersion: '1.0.0',
              ),
            ),
          ]),
        ],
      ),
    );
  }
}