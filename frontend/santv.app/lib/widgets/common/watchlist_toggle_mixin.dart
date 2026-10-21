import 'package:flutter/foundation.dart';
import 'package:santv_app/models/content.dart';
import 'package:santv_app/services/watchlist_service.dart';

/// Guardar / quitar videos de Mi Lista para cualquier controller
/// (ChangeNotifier) que muestre contenido con el marcador de guardado.
mixin WatchlistToggleMixin on ChangeNotifier {
  WatchlistService get watchlist;

  /// IDs de los contenidos guardados en Mi Lista (para pintar el marcador).
  Set<String> savedIds = {};

  bool disposed = false;

  void notifySafe() {
    if (!disposed) notifyListeners();
  }

  void _setSaved(String id, bool saved) {
    if (saved) {
      savedIds.add(id);
    } else {
      savedIds.remove(id);
    }
    notifySafe();
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
    if (disposed) return null;

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
    disposed = true;
    super.dispose();
  }
}