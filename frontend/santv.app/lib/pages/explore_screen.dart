import 'package:flutter/material.dart';
import '../widgets/publicidad_section.dart';
import '../widgets/explore/explore_search_bar.dart';
import '../widgets/explore/category_chips_row.dart';
import '../widgets/explore/explore_card.dart';
import '../models/categories.dart';
import '../models/content.dart';
import '../services/auth_service.dart';
import '../services/content_services.dart';
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
  String _query = ''; // NUEVO: texto de búsqueda
  late final ContentService _contentService;

  bool _cargando = true;
  List<ContentItem> _allContent = [];

  @override
  void initState() {
    super.initState();
    _contentService = ContentService(authService: widget.authService);
    _cargar();
  }

  Future<void> _cargar() async {
    final content = await _contentService.obtenerContenidoExplorar(limit: 30);
    if (!mounted) return;
    setState(() {
      _allContent = content;
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

  // CAMBIADO: filtra por categoría Y por texto de búsqueda
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

  Future<void> _abrirVideo(ContentItem content) async {
    if (content.isYoutube) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => YoutubePlayerScreen(content: content),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VideoPlayerScreen(content: content)),
      );
    }
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
                  onTap: () => _abrirVideo(item),
                );
              },
            ),
        ],
      ),
    );
  }
}