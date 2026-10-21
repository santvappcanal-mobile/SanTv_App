import 'package:flutter/foundation.dart';
import '../../models/categories.dart';
import '../../models/content.dart';
import '../../services/auth_service.dart';
import '../../services/content_services.dart';
import '../../services/watchlist_service.dart';

/// Estado y lógica de la pestaña Explorar: carga, filtros y Mi Lista.
class ExploreController extends ChangeNotifier {
  ExploreController({required AuthService authService})
    : _content = ContentService(authService: authService),
      watchlist = WatchlistService(authService: authService);

  final ContentService _content;
  final WatchlistService watchlist;

  int selectedCategory = 0;
  String query = ''; // texto de búsqueda
  bool cargando = true;
  List<ContentItem> allContent = [];

  /// IDs de los contenidos guardados en Mi Lista (para pintar el marcador).
  Set<String> savedIds = {};

  bool _disposed = false;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void setQuery(String value) {
    query = value;
    _notify();
  }

  void selectCategory(int index) {
    selectedCategory = index;
    _notify();
  }

  /// Carga el contenido y los guardados. Con [silencioso] = true no muestra
  /// el spinner (se usa para refrescar al volver del reproductor).
  Future<void> cargar({bool silencioso = false}) async {
    if (!silencioso) {
      cargando = true;
      _notify();
    }

    final results = await Future.wait([
      _content.obtenerContenidoExplorar(limit: 30),
      watchlist.obtenerIdsGuardados(),
    ]);
    if (_disposed) return;

    final content = results[0] as List<ContentItem>;
    final saved = results[1] as Set<String>;

    // Si el refresco silencioso falla (lista vacía), se conserva lo que ya había.
    if (!silencioso || content.isNotEmpty) {
      allContent = content;
    }
    savedIds = saved;
    cargando = false;
    _notify();
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
  List<ContentItem> get filteredContent {
    Iterable<ContentItem> result = allContent;

    if (selectedCategory != 0) {
      final category = normalizeCategory(kCategories[selectedCategory]);
      result = result.where(
        (c) => c.genres.any((g) => normalizeCategory(g) == category),
      );
    }

    final q = _normalize(query);
    if (q.isNotEmpty) {
      result = result.where((c) => _normalize(c.title).contains(q));
    }

    return result.toList();
  }

  void _setSaved(String id, bool saved) {
    if (saved) {
      savedIds.add(id);
    } else {
      savedIds.remove(id);
    }
    _notify();
  }

  /// Guarda o quita un video de Mi Lista (cambio optimista con reversa si
  /// falla). Devuelve el mensaje a mostrar, o null si la pantalla ya se cerró.
  Future<({bool ok, String message})?> toggleGuardado(
    ContentItem content,
  ) async {
    final estabaGuardado = savedIds.contains(content.id);
    _setSaved(content.id, !estabaGuardado);

    final ok = estabaGuardado
        ? await watchlist.quitar(content.id)
        : await watchlist.agregar(content.id);
    if (_disposed) return null;

    if (!ok) {
      _setSaved(content.id, estabaGuardado);
      return (ok: false, message: 'No se pudo actualizar Mi Lista.');
    }
    return (
      ok: true,
      message: estabaGuardado ? 'Eliminado de Mi Lista' : 'Agregado a Mi Lista',
    );
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}