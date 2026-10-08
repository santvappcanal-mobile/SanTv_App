import 'package:flutter/material.dart';
import '../../services/watchlist_service.dart';

/// Botón de marcador para guardar/quitar un contenido de Mi Lista.
/// Maneja su propio estado (optimista): cambia el ícono al instante y
/// revierte si el servidor falla.
class SaveToListButton extends StatefulWidget {
  const SaveToListButton({
    super.key,
    required this.contentId,
    required this.watchlistService,
    this.initialSaved = false,
    this.color = const Color(0xFF39FF14),
  });

  final String contentId;
  final WatchlistService watchlistService;
  final bool initialSaved;
  final Color color;

  @override
  State<SaveToListButton> createState() => _SaveToListButtonState();
}

class _SaveToListButtonState extends State<SaveToListButton> {
  late bool _saved;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _saved = widget.initialSaved;
  }

  Future<void> _toggle() async {
    if (_busy) return;
    _busy = true;

    final wasSaved = _saved;
    setState(() => _saved = !wasSaved);

    final ok = wasSaved
        ? await widget.watchlistService.quitar(widget.contentId)
        : await widget.watchlistService.agregar(widget.contentId);

    _busy = false;
    if (!mounted) return;

    if (!ok) {
      setState(() => _saved = wasSaved);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar Mi Lista.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          wasSaved ? 'Eliminado de Mi Lista' : 'Agregado a Mi Lista',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: _saved ? 'Quitar de Mi Lista' : 'Guardar en Mi Lista',
      onPressed: _toggle,
      icon: Icon(
        _saved ? Icons.bookmark : Icons.bookmark_border,
        color: _saved ? widget.color : Colors.white,
      ),
    );
  }
}