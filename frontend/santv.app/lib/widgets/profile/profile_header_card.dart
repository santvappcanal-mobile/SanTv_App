import 'package:flutter/material.dart';
import '../common/glass_container.dart';
import 'profile_avatar.dart';

/// Encabezado del perfil: avatar con borde neón, nombre y correo.
/// Si se pasa [onAvatarTap], el círculo se vuelve tocable y muestra un lápiz.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.userName,
    required this.userEmail,
    this.avatarUrl,
    this.onAvatarTap,
  });

  final String userName;
  final String userEmail;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;

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
          GestureDetector(
            onTap: onAvatarTap,
            child: Stack(
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
                  child: ProfileAvatar(avatar: avatarUrl, radius: 42),
                ),
                if (onAvatarTap != null)
                  const Positioned(
                    bottom: 2,
                    right: 2,
                    child: CircleAvatar(
                      radius: 13,
                      backgroundColor: _neonGreen,
                      child: Icon(Icons.edit, size: 14, color: Colors.black),
                    ),
                  ),
              ],
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
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}