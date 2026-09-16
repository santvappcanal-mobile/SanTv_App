import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/publicidad_section.dart';
import '../widgets/explore/explore_search_bar.dart';
import '../widgets/explore/category_chips_row.dart';
import '../widgets/explore/explore_card.dart';
import '../models/content.dart';
import '../services/auth_service.dart';
import '../services/content_services.dart';
import 'video_player_screen.dart';

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
  late final ContentService _contentService;

  bool _cargando = true;
  List<ContentItem> _allContent = [];

  final List<String> _categories = const [
    'Todo',
    'Deportes',
    'Noticias',
    'Música',
    'Gaming',
    'Educación',
  ];

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

  List<ContentItem> get _filteredContent {
    if (_selectedCategory == 0) return _allContent; // "Todo"
    final category = _categories[_selectedCategory].toLowerCase();
    return _allContent
        .where((c) => c.genres.any((g) => g.toLowerCase() == category))
        .toList();
  }

  Future<void> _abrirVideo(ContentItem content) async {
    if (content.isYoutube) {
      final uri = Uri.parse(content.videoUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
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

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExploreSearchBar(accentColor: neonColor),
          const SizedBox(height: 20),
          CategoryChipsRow(
            categories: _categories,
            selectedIndex: _selectedCategory,
            onSelected: (index) => setState(() => _selectedCategory = index),
            accentColor: neonColor,
          ),
          const SizedBox(height: 20),

          PublicidadSection(onTap: widget.onOpenAdvertising),
          const SizedBox(height: 24),

          const Text(
            'Contenido para ti',
            style: TextStyle(
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No hay contenido en esta categoría todavía',
                  style: TextStyle(color: Colors.white54),
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
