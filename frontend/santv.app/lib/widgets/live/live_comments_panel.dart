import 'dart:async';

import 'package:flutter/material.dart';
import 'package:santv_app/models/live_comment.dart';
import 'package:santv_app/services/live_comment_service.dart';
import 'package:santv_app/widgets/live/live_comment_input_bar.dart';
import 'package:santv_app/widgets/live/live_comment_tile.dart';

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
    super.dispose();
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
          itemBuilder: (context, index) => LiveCommentTile(
            comment: comments[comments.length - 1 - index],
            overlay: overlay,
          ),
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

    return Container(
      color: overlay ? Colors.transparent : const Color(0xFF0B0B0B),
      child: Column(
        children: [
          Expanded(child: list),
          LiveCommentInputBar(
            overlay: overlay,
            onSend: (text) => widget.service.send(text),
          ),
        ],
      ),
    );
  }
}