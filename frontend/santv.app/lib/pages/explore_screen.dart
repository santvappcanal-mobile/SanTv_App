import 'package:flutter/material.dart';
import '../models/content.dart';
import '../services/auth_service.dart';
import '../widgets/explore/explore_widgets.dart';
import 'video_player_screen.dart';
import 'youtube_player_screen.dart';

/// Pestaña "Explorar". Se usa embebida dentro de [Home]
/// (pages/home.dart), como uno de los ítems del IndexedStack.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
    required this.onOpenAdvertising,
    required this.authService,
  });

  final VoidCallback onOpenAdvertising;
  final AuthService authService;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final ExploreController _c;

  @override
  void initState() {
    super.initState();
    _c = ExploreController(authService: widget.authService)..cargar();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _toggleGuardado(ContentItem content) async {
    final r = await _c.toggleGuardado(content);
    if (r == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: r.ok ? 2 : 4),
        content: Text(r.message),
      ),
    );
  }

  /// Al tocar un video: lo registra como visto (suma la vista pública solo
  /// la primera vez que este usuario lo ve), abre el reproductor y, al volver,
  /// refresca la lista para mostrar el contador y los guardados actualizados.
  Future<void> _abrirVideo(ContentItem content) async {
    // Se dispara de inmediato, sin bloquear la apertura del reproductor.
    final vistoFuture = _c.watchlist.registrarVisto(content.id);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => content.isYoutube
            ? YoutubePlayerScreen(
                content: content,
                authService: widget.authService,
                watchlistService: _c.watchlist,
                initialSaved: _c.savedIds.contains(content.id),
              )
            : VideoPlayerScreen(
                content: content,
                authService: widget.authService,
                watchlistService: _c.watchlist,
                initialSaved: _c.savedIds.contains(content.id),
              ),
      ),
    );

    // Nos aseguramos de que el registro ya quedó guardado antes de recargar.
    await vistoFuture;
    if (!mounted) return;
    await _c.cargar(silencioso: true);
  }

  @override
  Widget build(BuildContext context) {
    final neonColor = Theme.of(context).colorScheme.primary;

    return ListenableBuilder(
      listenable: _c,
      builder: (context, _) => SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExploreHeader(
              accentColor: neonColor,
              selectedCategory: _c.selectedCategory,
              onQueryChanged: _c.setQuery,
              onCategorySelected: _c.selectCategory,
              onOpenAdvertising: widget.onOpenAdvertising,
            ),
            ExploreResults(
              items: _c.filteredContent,
              cargando: _c.cargando,
              query: _c.query,
              savedIds: _c.savedIds,
              accentColor: neonColor,
              onToggleSave: _toggleGuardado,
              onTap: _abrirVideo,
            ),
          ],
        ),
      ),
    );
  }
}