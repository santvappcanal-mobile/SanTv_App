import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../models/comment.dart';
import '../../services/auth_service.dart';
import '../../services/comment_service.dart';
import '../profile/profile_avatar.dart';
import 'glass_container.dart';

/// Caja de comentarios de un video: lista con scroll + campo para escribir
/// pegado abajo. Se usa en los dos reproductores (YouTube y video subido).
/// Ocupa todo el alto que le dé su padre, así que va dentro de un Expanded.
class CommentsSection extends StatefulWidget {
  const CommentsSection({
    super.key,
    required this.contentId,
    required this.authService,
  });

  final String contentId;
  final AuthService authService;

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  static const Color _neon = Color(0xFF39FF14);
  static const int _pageSize = 20;

  late final CommentService _service =
      CommentService(authService: widget.authService);
  final _ctrl = TextEditingController();
  final List<CommentItem> _items = [];

  AppUser? _me;
  bool _loading = true;
  bool _loadingMore = false;
  bool _sending = false;
  bool _failed = false;
  bool _hasMore = false;
  int _total = 0;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _loadFirst();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ───────────────────────── Datos ─────────────────────────

  Future<void> _loadFirst() async {
    setState(() {
      _loading = true;
      _failed = false;
    });

    final results = await Future.wait<Object?>([
      _service.getComments(widget.contentId, page: 1, limit: _pageSize),
      widget.authService.getProfile(),
    ]);

    if (!mounted) return;

    final page = results[0] as CommentsPage?;
    final me = results[1] as AppUser?;

    setState(() {
      _me = me;
      _loading = false;
      if (page == null) {
        _failed = true;
      } else {
        _items
          ..clear()
          ..addAll(page.items);
        _total = page.total;
        _hasMore = page.hasMore;
        _page = 1;
      }
    });
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);

    final page = await _service.getComments(
      widget.contentId,
      page: _page + 1,
      limit: _pageSize,
    );

    if (!mounted) return;

    setState(() {
      _loadingMore = false;
      if (page != null) {
        _page += 1;
        final known = _items.map((c) => c.id).toSet();
        _items.addAll(page.items.where((c) => !known.contains(c.id)));
        _total = page.total;
        _hasMore = page.hasMore;
      }
    });
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    final result = await _service.addComment(widget.contentId, text);
    if (!mounted) return;
    setState(() => _sending = false);

    if (result.success && result.comment != null) {
      setState(() {
        _items.insert(0, result.comment!);
        _total += 1;
      });
      _ctrl.clear();
      FocusScope.of(context).unfocus();
    } else {
      _snack(result.errorMessage ?? 'No se pudo publicar el comentario');
    }
  }

  Future<void> _delete(CommentItem comment) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text(
          '¿Borrar comentario?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Esta acción no se puede deshacer.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Borrar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final result = await _service.deleteComment(widget.contentId, comment.id);
    if (!mounted) return;

    if (result.success) {
      setState(() {
        _items.removeWhere((c) => c.id == comment.id);
        if (_total > 0) _total -= 1;
      });
    } else {
      _snack(result.errorMessage ?? 'No se pudo borrar el comentario');
    }
  }

  void _snack(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1A1A1A),
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  bool _canDelete(CommentItem c) =>
      _me != null && (_me!.isAdmin || _me!.id == c.userId);

  String _ago(DateTime? date) {
    if (date == null) return '';
    final local = date.toLocal();
    final diff = DateTime.now().difference(local);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'hace ${diff.inDays} d';
    return '${local.day}/${local.month}/${local.year}';
  }

  // ───────────────────────── UI ─────────────────────────

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: GlassContainer(
        borderRadius: 24,
        blurSigma: 14,
        gradientColors: [
          Colors.white.withValues(alpha: 0.10),
          Colors.white.withValues(alpha: 0.03),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: _neon.withValues(alpha: 0.08),
            blurRadius: 30,
            spreadRadius: -6,
          ),
        ],
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _header(),
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
            Expanded(child: _body()),
            _inputBar(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          const Icon(Icons.chat_bubble_outline, color: _neon, size: 18),
          const SizedBox(width: 10),
          const Text(
            'Comentarios',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _neon.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _neon.withValues(alpha: 0.4)),
            ),
            child: Text(
              '$_total',
              style: const TextStyle(
                color: _neon,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _neon));
    }

    if (_failed) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No se pudieron cargar los comentarios',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
            TextButton(
              onPressed: _loadFirst,
              child: const Text('Reintentar', style: TextStyle(color: _neon)),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 34,
              color: Colors.white.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 8),
            Text(
              'Sé el primero en comentar',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      itemCount: _items.length + (_hasMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return Center(
            child: _loadingMore
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _neon,
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: _loadMore,
                    child: const Text(
                      'Ver más comentarios',
                      style: TextStyle(color: _neon),
                    ),
                  ),
          );
        }
        return _commentTile(_items[index]);
      },
    );
  }

  Widget _commentTile(CommentItem c) {
    final isMine = _me != null && _me!.id == c.userId;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileAvatar(avatar: c.userAvatar, radius: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        c.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isMine ? _neon : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _ago(c.createdAt),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  c.text,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (_canDelete(c))
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _delete(c),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _inputBar() {
    final canWrite = _me != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 10, 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ProfileAvatar(avatar: _me?.avatarUrl, radius: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _ctrl,
              enabled: canWrite,
              minLines: 1,
              maxLines: 4,
              maxLength: 500,
              buildCounter: (
                context, {
                required currentLength,
                required isFocused,
                required maxLength,
              }) =>
                  null,
              textCapitalization: TextCapitalization.sentences,
              cursorColor: _neon,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: canWrite
                    ? 'Escribe un comentario...'
                    : 'Inicia sesión para comentar',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.07),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide(color: _neon.withValues(alpha: 0.6)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _ctrl,
            builder: (context, value, child) {
              final canSend =
                  value.text.trim().isNotEmpty && !_sending && canWrite;
              return SizedBox(
                width: 44,
                height: 44,
                child: FilledButton(
                  onPressed: canSend ? _send : null,
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                    backgroundColor: _neon,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor:
                        Colors.white.withValues(alpha: 0.12),
                    disabledForegroundColor:
                        Colors.white.withValues(alpha: 0.35),
                  ),
                  child: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 20),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}