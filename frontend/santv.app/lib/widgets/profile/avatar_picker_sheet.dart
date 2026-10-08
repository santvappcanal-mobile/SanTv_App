import 'package:flutter/material.dart';
import 'profile_avatar.dart';

const _card = Color(0xFF1A1A1A);
const _neon = Color(0xFF39FF14);

/// Menú inferior: Galería, Cámara, Elegir avatar y Quitar.
Future<void> showAvatarOptions(
  BuildContext context, {
  required VoidCallback onGallery,
  required VoidCallback onCamera,
  required ValueChanged<String> onAvatar,
  required VoidCallback onRemove,
  required bool hasAvatar,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: _card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetCtx) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined, color: _neon),
            title: const Text('Galería', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(sheetCtx);
              onGallery();
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined, color: _neon),
            title: const Text('Cámara', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(sheetCtx);
              onCamera();
            },
          ),
          ListTile(
            leading: const Icon(Icons.face_outlined, color: _neon),
            title: const Text('Elegir avatar',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(sheetCtx);
              _showAvatarGrid(context, onAvatar);
            },
          ),
          if (hasAvatar)
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Quitar foto / avatar',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(sheetCtx);
                onRemove();
              },
            ),
        ],
      ),
    ),
  );
}

void _showAvatarGrid(BuildContext context, ValueChanged<String> onAvatar) {
  showModalBottomSheet(
    context: context,
    backgroundColor: _card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetCtx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Elige tu avatar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: kAvatarOptions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
              ),
              itemBuilder: (_, i) {
                final option = kAvatarOptions[i];
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    onAvatar(option.id);
                  },
                  child: ProfileAvatar(avatar: option.id, radius: 32),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}