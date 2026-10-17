import 'dart:async';

import 'package:flutter/material.dart';
import 'package:santv_app/models/live_comment.dart';
import 'package:santv_app/services/live_comment_service.dart';

/// Lista de comentarios en vivo + caja para escribir.
///
/// [overlay] = true: estilo Facebook Live en horizontal (fondo
/// transparente, burbujas semitransparentes sobre el video).
/// [overlay] = false: panel normal debajo del video (vertical).
class LiveCommentsPanel extends StatefulWidget {
  const LiveCommentsPanel({
    super.key,
    required this.service,
    this.overlay = false,
  });

  final LiveCommentService service;
  final bool overlay;

  @override
  State<LiveCommentsPanel> createState() => _LiveCommentsPanelState();
}

class _LiveCommentsPanelState extends State<LiveCommentsPanel> {
  static const Color _neon = Color(0xFF39FF14);

  final TextEditingController _input = TextEditingController();
  StreamSubscription<String>? _errorSub;

  @override
  void initState() {
    super.initState();
    _errorSub = widget.service.errorStream.listen((msg) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(msg)));
    });
  }

  @override
  void dispose() {
    _errorSub?.cancel();
    _input.dispose();
    super.dispose();
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    widget.service.send(text);
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final overlay = widget.overlay;

    final list = StreamBuilder<List<LiveComment>>(
      stream: widget.service.commentsStream,
      initialData: widget.service.current,
      builder: (context, snap) {
        final comments = snap.data ?? const <LiveComment>[];

        if (comments.isEmpty) {
          return overlay
              ? const SizedBox.shrink()
              : const Center(
                  child: Text(
                    'Sé el primero en comentar',
                    style: TextStyle(color: Colors.white54),
                  ),
                );
        }

        final listView = ListView.builder(
          reverse: true, // lo más nuevo abajo, pegado a la caja de texto
          padding: EdgeInsets.symmetric(
            horizontal: overlay ? 0 : 12,
            vertical: 8,
          ),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final c = comments[comments.length - 1 - index];
            return _CommentTile(comment: c, overlay: overlay);
          },
        );

        if (!overlay) return listView;

        // Desvanece los comentarios viejos hacia arriba.
        return ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black],
            stops: [0.0, 0.25],
          ).createShader(rect),
          blendMode: BlendMode.dstIn,
          child: listView,
        );
      },
    );

    final inputBar = Padding(
      padding: EdgeInsets.fromLTRB(overlay ? 0 : 12, 4, overlay ? 0 : 12, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _input,
              maxLength: 300,
              maxLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                counterText: '',
                hintText: 'Escribe un comentario…',
                hintStyle: const TextStyle(color: Colors.white54),
                isDense: true,
                filled: true,
                fillColor: overlay
                    ? Colors.black.withOpacity(0.45)
                    : const Color(0xFF1A1A1A),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: _neon,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );

    return Container(
      color: overlay ? Colors.transparent : const Color(0xFF0B0B0B),
      child: Column(
        children: [
          Expanded(child: list),
          inputBar,
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment, required this.overlay});

  final LiveComment comment;
  final bool overlay;

  @override
  Widget build(BuildContext context) {
    final initial =
        comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : '?';

    final avatar = CircleAvatar(
      radius: 14,
      backgroundColor: const Color(0xFF2A2A2A),
      backgroundImage:
          comment.avatarUrl.startsWith('http') ? NetworkImage(comment.avatarUrl) : null,
      child: comment.avatarUrl.startsWith('http')
          ? null
          : Text(initial, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );

    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: overlay
            ? Colors.black.withOpacity(0.45)
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
