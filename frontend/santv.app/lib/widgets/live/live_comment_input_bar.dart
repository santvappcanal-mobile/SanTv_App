import 'package:flutter/material.dart';

/// Caja para escribir un comentario + botón de enviar.
class LiveCommentInputBar extends StatefulWidget {
  const LiveCommentInputBar({
    super.key,
    required this.onSend,
    this.overlay = false,
  });

  final ValueChanged<String> onSend;
  final bool overlay;

  @override
  State<LiveCommentInputBar> createState() => _LiveCommentInputBarState();
}

class _LiveCommentInputBarState extends State<LiveCommentInputBar> {
  static const Color _neon = Color(0xFF39FF14);

  final TextEditingController _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final overlay = widget.overlay;

    return Padding(
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
                    ? Colors.black.withValues(alpha: 0.45)
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
              child: const Icon(
                Icons.send_rounded,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}