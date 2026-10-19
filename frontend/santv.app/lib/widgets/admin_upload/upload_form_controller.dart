import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/content_services.dart';

/// Guarda los campos y el estado del formulario de subida de contenido.
/// Notifica a la UI cuando cambia algo que no sea texto escrito.
class UploadFormController extends ChangeNotifier {
  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final thumbnailCtrl = TextEditingController();
  final durationCtrl = TextEditingController();
  final yearCtrl = TextEditingController();
  final videoUrlCtrl = TextEditingController();

  String type = 'movie';
  String? category; // Deportes / Noticias / Educación
  bool isPremium = false;
  bool usarUrlExterna = false; // alterna entre subir archivo o pegar link
  File? videoFile;
  String? videoFileName;

  String get title => titleCtrl.text.trim();
  String get description => descriptionCtrl.text.trim();
  String get thumbnailUrl => thumbnailCtrl.text.trim();
  String get videoUrl => videoUrlCtrl.text.trim();
  int? get duration => int.tryParse(durationCtrl.text.trim());
  int? get releaseYear => int.tryParse(yearCtrl.text.trim());

  void setType(String v) => _set(() => type = v);
  void setCategory(String v) => _set(() => category = v);
  void setPremium(bool v) => _set(() => isPremium = v);
  void setUsarUrl(bool v) => _set(() => usarUrlExterna = v);
  void setVideo(File file, String name) => _set(() {
    videoFile = file;
    videoFileName = name;
  });

  void _set(VoidCallback change) {
    change();
    notifyListeners();
  }

  bool _esUrlValida(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.hasScheme &&
        (uri.isScheme('http') || uri.isScheme('https'));
  }

  /// Devuelve el mensaje de error, o null si todo está bien.
  String? validar() {
    if (category == null) return 'Selecciona una categoría.';
    if (usarUrlExterna) {
      if (!_esUrlValida(videoUrl)) {
        return 'Ingresa una URL de video válida (http/https).';
      }
    } else if (videoFile == null) {
      return 'Debes seleccionar un archivo de video.';
    }
    return null;
  }

  /// Sube el video o crea el contenido con URL externa, según el modo.
  Future<({bool ok, String message})> guardar(ContentService service) async {
    final result = usarUrlExterna
        ? await service.crearConUrlExterna(
            title: title,
            description: description,
            type: type,
            videoUrl: videoUrl,
            genres: category!,
            thumbnailUrl: thumbnailUrl,
            duration: duration,
            releaseYear: releaseYear,
            isPremium: isPremium,
          )
        : await service.subirVideo(
            title: title,
            description: description,
            type: type,
            videoFile: videoFile!,
            genres: category!,
            thumbnailUrl: thumbnailUrl,
            duration: duration,
            releaseYear: releaseYear,
            isPremium: isPremium,
          );
    return (
      ok: result.success,
      message: result.success
          ? 'Contenido guardado correctamente.'
          : (result.errorMessage ?? 'Ocurrió un error al guardar el contenido.'),
    );
  }

  void reset() {
    for (final c in [
      titleCtrl,
      descriptionCtrl,
      thumbnailCtrl,
      durationCtrl,
      yearCtrl,
      videoUrlCtrl,
    ]) {
      c.clear();
    }
    _set(() {
      type = 'movie';
      category = null;
      isPremium = false;
      usarUrlExterna = false;
      videoFile = null;
      videoFileName = null;
    });
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    thumbnailCtrl.dispose();
    durationCtrl.dispose();
    yearCtrl.dispose();
    videoUrlCtrl.dispose();
    super.dispose();
  }
}