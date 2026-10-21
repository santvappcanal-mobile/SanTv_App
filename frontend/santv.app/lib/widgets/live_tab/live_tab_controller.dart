import 'package:flutter/foundation.dart';
import 'package:santv_app/models/content.dart';
import 'package:santv_app/services/auth_service.dart';
import 'package:santv_app/services/content_services.dart';
import 'package:santv_app/services/watchlist_service.dart';
import 'package:santv_app/widgets/common/watchlist_toggle_mixin.dart';

/// Estado y lógica de la pestaña En vivo: carga de las transmisiones
/// que el admin marcó y Mi Lista (con [WatchlistToggleMixin]).
class LiveTabController extends ChangeNotifier with WatchlistToggleMixin {
  LiveTabController({required AuthService authService})
    : _content = ContentService(authService: authService),
      watchlist = WatchlistService(authService: authService);

  final ContentService _content;

  @override
  final WatchlistService watchlist;

  bool cargando = true;
  List<ContentItem> videos = [];

  /// Carga las transmisiones y los guardados. Con [silencioso] = true no
  /// muestra el spinner (se usa para refrescar al volver a la pestaña).
  Future<void> cargar({bool silencioso = false}) async {
    if (!silencioso) {
      cargando = true;
      notifySafe();
    }

    final results = await Future.wait([
      _content.obtenerContenidoEnVivo(limit: 30),
      watchlist.obtenerIdsGuardados(),
    ]);
    if (disposed) return;

    final nuevos = results[0] as List<ContentItem>;
    final saved = results[1] as Set<String>;

    // Si el refresco silencioso falla (lista vacía), se conserva lo anterior.
    if (!silencioso || nuevos.isNotEmpty) videos = nuevos;
    savedIds = saved;
    cargando = false;
    notifySafe();
  }
}