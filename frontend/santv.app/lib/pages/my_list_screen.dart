import 'package:flutter/material.dart';
import '../models/content.dart';
import '../services/auth_service.dart';
import '../services/watchlist_service.dart';
import '../widgets/explore/explore_card.dart';
import 'video_player_screen.dart';
import 'youtube_player_screen.dart';

/// Pantalla "Mi Lista": videos que el usuario guardó.
/// Se abre desde Perfil > Mi Lista con:
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => MyListScreen(authService: authService)));
class MyListScreen extends StatefulWidget {
  const MyListScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  static const _neon = Color(0xFF39FF14);

  late final WatchlistService _watchlistService;

  bool _cargando = true;
  List<ContentItem> _items = [];

  @override
  void initState() {
    super.initState();
    _watchlistService = WatchlistService(authService: widget.authService);
    _cargar();
  }

  Future<void> _cargar({bool silencioso = false}) async {
    if (!silencioso) setState(() => _cargando = true);

    final items = await _watchlistService.obtenerMiLista();
    if (!mounted) return;

    setState(() {
      _items = items;
      _cargando = false;
    });
  }

  /// Quita un video de Mi Lista (optimista, con reversa si falla).
  Future<void> _quitar(ContentItem content) async {
    final indexOriginal = _items.indexWhere((c) => c.id == content.id);
    if (indexOriginal == -1) return;

    setState(() => _items.removeAt(indexOriginal));

    final ok = await _watchlistService.quitar(content.id);
    if (!mounted) return;

    if (!ok) {
      setState(() => _items.insert(indexOriginal, content));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo quitar de Mi Lista.')),
      );
    }
  }

  Future<void> _abrirVideo(ContentItem content) async {
    final vistoFuture = _watchlistService.registrarVisto(content.id);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => content.isYoutube
            ? YoutubePlayerScreen(
                content: content,
                watchlistService: _watchlistService,
                initialSaved: true,
              )
            : VideoPlayerScreen(
                content: content,
                watchlistService: _watchlistService,
                initialSaved: true,
              ),
      ),
    );

    await vistoFuture;
    if (!mounted) return;
    // Al volver, se refresca por si lo quitó desde el reproductor.
    await _cargar(silencioso: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Mi Lista',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: _neon))
          : _items.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Aún no has guardado videos.\nToca el marcador en cualquier video para agregarlo aquí.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            )
          : RefreshIndicator(
              color: _neon,
              onRefresh: () => _cargar(silencioso: true),
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                itemCount: _items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return ExploreCard(
                    accentColor: _neon,
                    content: item,
                    isSaved: true,
                    onToggleSave: () => _quitar(item),
                    onTap: () => _abrirVideo(item),
                  );
                },
              ),
            ),
    );
  }
}