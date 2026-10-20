import 'package:flutter/material.dart';
import 'package:santv_app/widgets/explore/explore_card.dart';
import 'package:santv_app/widgets/live/live_channel_player.dart';
import 'package:santv_app/widgets/live_tab/pulsing_live_dot.dart';
import '../models/content.dart';
import '../services/auth_service.dart';
import '../services/content_services.dart';
import '../services/watchlist_service.dart';
import 'video_player_screen.dart';
import 'youtube_player_screen.dart';

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
  late final ContentService _contentService;
  late final WatchlistService _watchlistService;

  bool _cargando = true;
  List<ContentItem> _videos = [];
  Set<String> _savedIds = {};

  @override
  void initState() {
    super.initState();
    _contentService = ContentService(authService: widget.authService);
    _watchlistService = WatchlistService(authService: widget.authService);
    _cargar();
  }

  @override
  void didUpdateWidget(covariant LiveTabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Al volver a esta pestaña se refresca la lista (por si el admin
    // agregó videos nuevos).
    if (!oldWidget.isActive && widget.isActive) {
      _cargar(silencioso: true);
    }
  }

  Future<void> _cargar({bool silencioso = false}) async {
    if (!silencioso) setState(() => _cargando = true);

    final results = await Future.wait([
      _contentService.obtenerContenidoEnVivo(limit: 30),
      _watchlistService.obtenerIdsGuardados(),
    ]);
    if (!mounted) return;

    final videos = results[0] as List<ContentItem>;
    final saved = results[1] as Set<String>;

    setState(() {
      // Si el refresco silencioso falla (lista vacía), se conserva lo anterior.
      if (!silencioso || videos.isNotEmpty) _videos = videos;
      _savedIds = saved;
      _cargando = false;
    });
  }

  /// Guarda o quita un video de Mi Lista (cambio optimista con reversa si falla).
  Future<void> _toggleGuardado(ContentItem content) async {
    final estabaGuardado = _savedIds.contains(content.id);

    setState(() {
      if (estabaGuardado) {
        _savedIds.remove(content.id);
      } else {
        _savedIds.add(content.id);
      }
    });

    final ok = estabaGuardado
        ? await _watchlistService.quitar(content.id)
        : await _watchlistService.agregar(content.id);
    if (!mounted) return;

    if (!ok) {
      setState(() {
        if (estabaGuardado) {
          _savedIds.add(content.id);
        } else {
          _savedIds.remove(content.id);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar Mi Lista.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          estabaGuardado ? 'Eliminado de Mi Lista' : 'Agregado a Mi Lista',
        ),
      ),
    );
  }

  /// Igual que en Explorar: registra la vista, abre el reproductor y al
  /// volver refresca la lista.
  Future<void> _abrirVideo(ContentItem content) async {
    final vistoFuture = _watchlistService.registrarVisto(content.id);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => content.isYoutube
            ? YoutubePlayerScreen(
                content: content,
                authService: widget.authService,
                watchlistService: _watchlistService,
                initialSaved: _savedIds.contains(content.id),
              )
            : VideoPlayerScreen(
                content: content,
                authService: widget.authService,
                watchlistService: _watchlistService,
                initialSaved: _savedIds.contains(content.id),
              ),
      ),
    );

    await vistoFuture;
    if (!mounted) return;
    await _cargar(silencioso: true);
  }

  @override
  Widget build(BuildContext context) {
    final neonColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              PulsingLiveDot(),
              SizedBox(width: 8),
              Text(
                'Canal en vivo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Canal permanente de SAN TV, reproduciéndose en autoplay.
          LiveChannelPlayer(
            isActive: widget.isActive,
            showLiveBadge: false,
            authService: widget.authService,
          ),

          // Videos que el admin marcó para esta pestaña.
          if (_cargando)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF39FF14)),
              ),
            )
          else if (_videos.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Más transmisiones',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _videos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final item = _videos[index];
                return ExploreCard(
                  accentColor: neonColor,
                  content: item,
                  isSaved: _savedIds.contains(item.id),
                  onToggleSave: () => _toggleGuardado(item),
                  onTap: () => _abrirVideo(item),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}