import 'package:flutter/foundation.dart';
import 'package:santv_app/models/ad_document_item.dart';
import 'package:santv_app/models/gallery_item.dart';
import 'package:santv_app/models/reference_video_item.dart';
import 'package:santv_app/services/ad_service.dart';

/// Estado de una lista que se carga del backend (spinner, error, datos).
class LoadableList<T> {
  List<T> items = [];
  bool cargando = true;
  String? error;
}

/// Estado y carga de las 3 pestañas de Publicidad:
/// Referencias (videos), Documentos (PDF) y Portafolio (imágenes).
class PublicidadController extends ChangeNotifier {
  PublicidadController({required this.adService});

  final AdService adService;

  final documentos = LoadableList<AdDocumentItem>();
  final referencias = LoadableList<ReferenceVideoItem>();
  final galeria = LoadableList<GalleryItem>();

  bool _disposed = false;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void cargarTodo() {
    cargarDocumentos();
    cargarReferencias();
    cargarGaleria();
  }

  Future<void> cargarDocumentos() => _cargar(
    documentos,
    adService.getDocuments,
    'Error al cargar documentos',
  );

  Future<void> cargarReferencias() => _cargar(
    referencias,
    adService.getReferences,
    'Error al cargar las referencias',
  );

  Future<void> cargarGaleria() =>
      _cargar(galeria, adService.getGallery, 'Error al cargar el portafolio');

  Future<void> _cargar<T>(
    LoadableList<T> estado,
    Future<List<T>> Function() traer,
    String mensajeError,
  ) async {
    estado.cargando = true;
    estado.error = null;
    _notify();
    try {
      final items = await traer();
      if (_disposed) return;
      estado.items = items;
      estado.cargando = false;
    } catch (_) {
      if (_disposed) return;
      estado.error = mensajeError;
      estado.cargando = false;
    }
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}