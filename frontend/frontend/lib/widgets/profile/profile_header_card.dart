import 'package:flutter/material.dart';
import '../common/glass_container.dart';
import '../common/glass_button.dart';

/// Encabezado del perfil: avatar con borde neón, nombre, correo
/// y botón de "Editar perfil".
/// Antes era _buildHeaderCard() dentro de profile_screen.dart.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.userName,
    required this.userEmail,
    this.avatarUrl,
    this.onEditProfile,
  });

  final String userName;
  final String userEmail;
  final String? avatarUrl;
  final VoidCallback? onEditProfile;

  static const Color _neonGreen = Color(0xFF39FF14);

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      gradientColors: [
        Colors.white.withValues(alpha: 0.10),
        Colors.white.withValues(alpha: 0.04),
      ],
      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      boxShadow: [
        BoxShadow(
          color: _neonGreen.withValues(alpha: 0.08),
          blurRadius: 30,
          spreadRadius: -6,
        ),
      ],
      child: Column(
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
            child: CircleAvatar(
              radius: 42,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? const Icon(Icons.person, size: 42, color: Colors.white70)
                  : null,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userEmail,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
          ),
          const SizedBox(height: 16),
          GlassButton(
            label: 'Editar perfil',
            icon: Icons.edit_outlined,
            onTap: onEditProfile,
          ),
        ],
      ),
    );
  }
}