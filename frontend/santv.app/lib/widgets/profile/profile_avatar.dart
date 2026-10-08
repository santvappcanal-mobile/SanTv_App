import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AvatarOption {
  final String id;
  final String emoji;
  final Color color;
  const AvatarOption(this.id, this.emoji, this.color);
}

/// Avatares prediseñados. El id es lo que se guarda en la base de datos.
const List<AvatarOption> kAvatarOptions = [
  AvatarOption('avatar:1', '🦊', Color(0xFFFF8A3D)),
  AvatarOption('avatar:2', '🐼', Color(0xFF9E9E9E)),
  AvatarOption('avatar:3', '🐯', Color(0xFFFFB300)),
  AvatarOption('avatar:4', '🐸', Color(0xFF39FF14)),
  AvatarOption('avatar:5', '🦁', Color(0xFFFF7043)),
  AvatarOption('avatar:6', '🐙', Color(0xFFAB47BC)),
  AvatarOption('avatar:7', '🐧', Color(0xFF29B6F6)),
  AvatarOption('avatar:8', '🦄', Color(0xFFEC407A)),
];

AvatarOption? avatarOptionFor(String? value) {
  if (value == null) return null;
  for (final o in kAvatarOptions) {
    if (o.id == value) return o;
  }
  return null;
}

/// Muestra el avatar del usuario: avatar prediseñado, foto por URL,
/// o el ícono de persona si no hay nada.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.avatar, required this.radius});

  final String? avatar;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final option = avatarOptionFor(avatar);

    if (option != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: option.color.withValues(alpha: 0.28),
        child: Text(option.emoji, style: TextStyle(fontSize: radius * 1.05)),
      );
    }

    if (avatar != null && avatar!.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white.withValues(alpha: 0.08),
        backgroundImage: CachedNetworkImageProvider(avatar!),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white.withValues(alpha: 0.08),
      child: Icon(Icons.person, size: radius, color: Colors.white70),
    );
  }
}