import 'package:flutter/material.dart';
import 'package:santv_app/models/live_comment.dart';

/// Un comentario: avatar + burbuja con nombre y texto.
/// [overlay] = true usa la burbuja semitransparente sobre el video.
class LiveCommentTile extends StatelessWidget {
  const LiveCommentTile({
    super.key,
    required this.comment,
    required this.overlay,
  });

  final LiveComment comment;
  final bool overlay;

  @override
  Widget build(BuildContext context) {
    final initial =
        comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : '?';
    final hasPhoto = comment.avatarUrl.startsWith('http');

    final avatar = CircleAvatar(
      radius: 14,
      backgroundColor: const Color(0xFF2A2A2A),
      backgroundImage: hasPhoto ? NetworkImage(comment.avatarUrl) : null,
      child: hasPhoto
          ? null
          : Text(
              initial,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
    );

    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: overlay
            ? Colors.black.withValues(alpha: 0.45)
            : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            comment.userName,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            comment.text,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          avatar,
          const SizedBox(width: 8),
          Flexible(child: bubble),
        ],
      ),
    );
  }
}