import 'dart:async';
import 'package:flutter/material.dart';
import '../models/live_viewer.dart';
import '../services/live_viewer_service.dart';

/// Muestra, en tiempo real, cuántas personas están viendo el EN VIVO
/// y los avatares de algunas de ellas (estilo Facebook Live).
/// Al tocarla, abre la lista completa de espectadores conectados.
class LiveViewersBar extends StatefulWidget {
  const LiveViewersBar({super.key, required this.service});

  final LiveViewerService service;

  @override
  State<LiveViewersBar> createState() => _LiveViewersBarState();
}

class _LiveViewersBarState extends State<LiveViewersBar> {
  int _count = 0;
  List<LiveViewer> _viewers = [];
  StreamSubscription<int>? _countSub;
  StreamSubscription<List<LiveViewer>>? _viewersSub;

  @override
  void initState() {
    super.initState();
    _count = widget.service.currentCount;
    _viewers = widget.service.currentViewers;
    _countSub = widget.service.viewerCountStream.listen((c) {
      if (mounted) setState(() => _count = c);
    });
    _viewersSub = widget.service.viewersListStream.listen((v) {
      if (mounted) setState(() => _viewers = v);
    });
  }

  @override
  void dispose() {
    _countSub?.cancel();
    _viewersSub?.cancel();
    super.dispose();
  }

  void _showViewersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _ViewersListSheet(viewers: _viewers, count: _count),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preview = _viewers.take(3).toList();

    return InkWell(
      onTap: () => _showViewersSheet(context),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (preview.isNotEmpty)
              SizedBox(
                width: 16.0 + (preview.length - 1) * 16.0,
                height: 28,
                child: Stack(
                  children: [
                    for (int i = 0; i < preview.length; i++)
                      Positioned(
                        left: i * 16.0,
                        child: _ViewerAvatar(viewer: preview[i]),
                      ),
                  ],
                ),
              ),
            if (preview.isNotEmpty) const SizedBox(width: 6),
            Text(
              '$_count viendo',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewerAvatar extends StatelessWidget {
  const _ViewerAvatar({required this.viewer});

  final LiveViewer viewer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF121212), width: 2),
        color: const Color(0xFF2E7D32),
        image: viewer.avatarUrl != null
            ? DecorationImage(
                image: NetworkImage(viewer.avatarUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: viewer.avatarUrl == null
          ? Text(
              viewer.name.isNotEmpty ? viewer.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }
}

class _ViewersListSheet extends StatelessWidget {
  const _ViewersListSheet({required this.viewers, required this.count});

  final List<LiveViewer> viewers;
  final int count;

  String _tiempoDesde(DateTime fecha) {
    final diff = DateTime.now().difference(fecha);
    if (diff.inSeconds < 60) return 'justo ahora';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    return 'hace ${diff.inHours} h';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Viendo ahora ($count)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: viewers.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Aún no hay espectadores conectados.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: viewers.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: Colors.white12, height: 1),
                      itemBuilder: (context, index) {
                        final v = viewers[index];
                        return ListTile(
                          leading: _ViewerAvatar(viewer: v),
                          title: Text(
                            v.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: Text(
                            _tiempoDesde(v.joinedAt),
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}