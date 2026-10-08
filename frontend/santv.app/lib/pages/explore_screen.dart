import 'package:flutter/material.dart';
import '../widgets/publicidad_section.dart';
import '../widgets/explore/explore_search_bar.dart';
import '../widgets/explore/category_chips_row.dart';
import '../widgets/explore/explore_card.dart';
import '../models/categories.dart';
import '../models/content.dart';
import '../services/auth_service.dart';
import '../services/content_services.dart';
import '../services/watchlist_service.dart';
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
  int _selectedCategory = 0;
  String _query = ''; // texto de búsqueda
  late final ContentService _contentService;
  late final WatchlistService _watchlistService;

  bool _cargando = true;
  List<ContentItem> _allContent = [];

  /// IDs de los contenidos guardados en Mi Lista (para pintar el marcador).
  Set<String> _savedIds = {};

  @override
  void initState() {
    super.initState();
    _contentService = ContentService(authService: widget.authService);
    _watchlistService = WatchlistService(authService: widget.authService);
    _cargar();
  }

  /// Carga el contenido y los guardados. Con [silencioso] = true no muestra
  /// el spinner (se usa para refrescar al volver del reproductor).
  Future<void> _cargar({bool silencioso = false}) async {
    if (!silencioso) {
      setState(() => _cargando = true);
    }

    final results = await Future.wait([
      _contentService.obtenerContenidoExplorar(limit: 30),
      _watchlistService.obtenerIdsGuardados(),
    ]);
    if (!mounted) return;

    final content = results[0] as List<ContentItem>;
    final saved = results[1] as Set<String>;

    setState(() {
      // Si el refresco silencioso falla (lista vacía), se conserva lo que ya había.
      if (!silencioso || content.isNotEmpty) {
        _allContent = content;
      }
      _savedIds = saved;
      _cargando = false;
    });
  }

  /// Minúsculas y sin tildes, para que "Educación" coincida con "educacion".
  String _normalize(String s) {
    const from = 'áàäâéèëêíìïîóòöôúùüûñ';
    const to = 'aaaaeeeeiiiioooouuuun';
    var out = s.toLowerCase().trim();
    for (var i = 0; i < from.length; i++) {
      out = out.replaceAll(from[i], to[i]);
    }
    return out;
  }

  // Filtra por categoría Y por texto de búsqueda
  List<ContentItem> get _filteredContent {
    Iterable<ContentItem> result = _allContent;

    if (_selectedCategory != 0) {
      final category = normalizeCategory(kCategories[_selectedCategory]);
      result = result.where(
        (c) => c.genres.any((g) => normalizeCategory(g) == category),
      );
    }

    final q = _normalize(_query);
    if (q.isNotEmpty) {
      result = result.where((c) => _normalize(c.title).contains(q));
    }

    return result.toList();
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

  /// Al tocar un video: lo registra como visto (suma la vista pública solo
  /// la primera vez que este usuario lo ve), abre el reproductor y, al volver,
  /// refresca la lista para mostrar el contador y los guardados actualizados.
  Future<void> _abrirVideo(ContentItem content) async {
    // Se dispara de inmediato, sin bloquear la apertura del reproductor.
    final vistoFuture = _watchlistService.registrarVisto(content.id);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => content.isYoutube
            ? YoutubePlayerScreen(
                content: content,
                watchlistService: _watchlistService,
                initialSaved: _savedIds.contains(content.id),
              )
            : VideoPlayerScreen(
                content: content,
                watchlistService: _watchlistService,
                initialSaved: _savedIds.contains(content.id),
              ),
      ),
    );

    // Nos aseguramos de que el registro ya quedó guardado antes de recargar.
    await vistoFuture;
    if (!mounted) return;
    await _cargar(silencioso: true);
  }

  @override
  Widget build(BuildContext context) {
    final neonColor = Theme.of(context).colorScheme.primary;
    final filtered = _filteredContent;
    final buscando = _query.trim().isNotEmpty;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExploreSearchBar(
            accentColor: neonColor,
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 20),
          CategoryChipsRow(
            categories: kCategories,
            selectedIndex: _selectedCategory,
            onSelected: (index) => setState(() => _selectedCategory = index),
            accentColor: neonColor,
          ),
          const SizedBox(height: 20),

          PublicidadSection(onTap: widget.onOpenAdvertising),
          const SizedBox(height: 24),

          Text(
            buscando ? 'Resultados' : 'Contenido para ti',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),

          if (_cargando)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF39FF14)),
              ),
            )
          else if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  buscando
                      ? 'Sin resultados para "${_query.trim()}"'
                      : 'No hay contenido en esta categoría todavía',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final item = filtered[index];
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
      ),
    );
  }
}