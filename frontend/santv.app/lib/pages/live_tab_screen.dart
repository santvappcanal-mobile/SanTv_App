import 'package:flutter/material.dart';
import 'package:santv_app/models/content.dart';
import 'package:santv_app/services/auth_service.dart';
import 'package:santv_app/widgets/common/open_content_player.dart';
import 'package:santv_app/widgets/live/live_channel_player.dart';
import 'package:santv_app/widgets/live_tab/live_channel_header.dart';
import 'package:santv_app/widgets/live_tab/live_more_streams.dart';
import 'package:santv_app/widgets/live_tab/live_tab_controller.dart';

/// Pestaña "En Vivo". Se usa embebida dentro de [Home]
/// (pages/home.dart), como uno de los ítems del IndexedStack.
///
/// Arriba: el canal en vivo permanente (autoplay).
/// Abajo: los videos que el admin marcó con "Mostrar en la pestaña En vivo".
class LiveTabScreen extends StatefulWidget {
  const LiveTabScreen({
    super.key,
    required this.authService,
    this.onOpenLive,
    this.isActive = true,
  });

  final AuthService authService;

  /// Sin uso por ahora (se dejó para no romper Home).
  final void Function(String liveId)? onOpenLive;

  /// true cuando la pestaña En vivo es la visible. Si es false el
  /// video se pausa (evita que suene mientras el usuario está en
  /// otra pestaña, ya que el IndexedStack mantiene todo construido).
  final bool isActive;

  @override
  State<LiveTabScreen> createState() => _LiveTabScreenState();
}

class _LiveTabScreenState extends State<LiveTabScreen> {
  late final LiveTabController _c;

  @override
  void initState() {
    super.initState();
    _c = LiveTabController(authService: widget.authService)..cargar();
  }

  @override
  void didUpdateWidget(covariant LiveTabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Al volver a esta pestaña se refresca la lista (por si el admin
    // agregó videos nuevos).
    if (!oldWidget.isActive && widget.isActive) {
      _c.cargar(silencioso: true);
    }
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

  /// Igual que en Explorar: registra la vista, abre el reproductor y al
  /// volver refresca la lista.
  Future<void> _abrirVideo(ContentItem content) async {
    await openContentPlayer(
      context,
      content: content,
      authService: widget.authService,
      watchlist: _c.watchlist,
      initialSaved: _c.savedIds.contains(content.id),
    );
    if (!mounted) return;
    await _c.cargar(silencioso: true);
  }

  @override
  Widget build(BuildContext context) {
    final neonColor = Theme.of(context).colorScheme.primary;

    return ListenableBuilder(
      listenable: _c,
      builder: (context, _) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LiveChannelHeader(),
            const SizedBox(height: 12),

            // Canal permanente de SAN TV, reproduciéndose en autoplay.
            LiveChannelPlayer(
              isActive: widget.isActive,
              showLiveBadge: false,
              authService: widget.authService,
            ),

            // Videos que el admin marcó para esta pestaña.
            LiveMoreStreams(
              cargando: _c.cargando,
              items: _c.videos,
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