import 'package:flutter/material.dart';
import 'profile_avatar.dart';

/// Avatar grande con borde neón, lápiz de editar y spinner mientras sube.
class EditableAvatar extends StatelessWidget {
  const EditableAvatar({
    super.key,
    required this.avatar,
    required this.loading,
    required this.onTap,
  });

  static const Color _neon = Color(0xFF39FF14);

  final String? avatar;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: loading ? null : onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _neon, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: _neon.withValues(alpha: 0.4),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ProfileAvatar(avatar: avatar, radius: 52),
            ),
            if (loading) const CircularProgressIndicator(color: _neon),
            const Positioned(
              bottom: 2,
              right: 2,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: _neon,
                child: Icon(Icons.edit, size: 16, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}