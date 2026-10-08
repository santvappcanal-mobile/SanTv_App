import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/ad_service.dart';

class AdminAdsScreen extends StatefulWidget {
  const AdminAdsScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<AdminAdsScreen> createState() => _AdminAdsScreenState();
}

class _AdminAdsScreenState extends State<AdminAdsScreen> {
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color cardBg = Color(0xFF1A1A1A);

  late final AdService _adService;
  List<Map<String, dynamic>> _ads = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _adService = AdService(authService: widget.authService);
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final todos = await _adService.listarAdsAdmin();
      if (!mounted) return;
      setState(() {
        // Los PDF legales se manejan en Publicidad > Documentos
        _ads = todos.where((a) => a['type'] != 'document').toList();
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _nuevoAnuncio() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    final datos = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _DatosAnuncioDialog(imagen: File(picked.path)),
    );
    if (datos == null || !mounted) return;

    _mensaje('Subiendo anuncio...');
    final error = await _adService.subirAnuncioImagen(
      imagen: File(picked.path),
      titulo: datos['titulo']!,
      enlace: datos['enlace'],
    );
    if (!mounted) return;

    if (error == null) {
      _mensaje('Anuncio publicado');
      _cargar();
    } else {
      _mensaje(error);
    }
  }

  Future<void> _cambiarEstado(Map<String, dynamic> ad, bool activo) async {
    final ok = await _adService.cambiarEstadoAd(ad['_id'].toString(), activo);
    if (!mounted) return;
    if (ok) {
      setState(() => ad['isActive'] = activo);
    } else {
      _mensaje('No se pudo cambiar el estado');
    }
  }

  Future<void> _eliminar(Map<String, dynamic> ad) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        title: const Text(
          'Eliminar anuncio',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Eliminar "${ad['title']}"? No se puede deshacer.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    final ok = await _adService.eliminarAd(ad['_id'].toString());
    if (!mounted) return;
    if (ok) {
      _mensaje('Anuncio eliminado');
      _cargar();
    } else {
      _mensaje('No se pudo eliminar');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Anuncios', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargando ? null : _cargar,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: neonGreen,
        icon: const Icon(Icons.add_photo_alternate, color: Colors.black),
        label: const Text(
          'Subir imagen',
          style: TextStyle(color: Colors.black),
        ),
        onPressed: _nuevoAnuncio,
      ),
      body: _cuerpo(),
    );
  }

  Widget _cuerpo() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator(color: neonGreen));
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_ads.isEmpty) {
      return const Center(
        child: Text(
          'Aún no hay anuncios.\nToca "Subir imagen" para crear uno.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return RefreshIndicator(
      color: neonGreen,
      onRefresh: _cargar,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        itemCount: _ads.length,
        itemBuilder: (_, i) => _tarjeta(_ads[i]),
      ),
    );
  }

  Widget _tarjeta(Map<String, dynamic> ad) {
    final activo = ad['isActive'] == true;
    final url = (ad['mediaUrl'] ?? '').toString();
    final tipo = ad['type'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tipo != 'video' && url.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                url,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(
                  height: 160,
                  child: Center(
                    child: Icon(Icons.broken_image, color: Colors.white38),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (ad['title'] ?? 'Sin título').toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${ad['impressions'] ?? 0} vistas · ${ad['clicks'] ?? 0} clics',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: activo,
                  activeColor: neonGreen,
                  onChanged: (v) => _cambiarEstado(ad, v),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => _eliminar(ad),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DatosAnuncioDialog extends StatefulWidget {
  const _DatosAnuncioDialog({required this.imagen});

  final File imagen;

  @override
  State<_DatosAnuncioDialog> createState() => _DatosAnuncioDialogState();
}

class _DatosAnuncioDialogState extends State<_DatosAnuncioDialog> {
  final _titulo = TextEditingController();
  final _enlace = TextEditingController();

  @override
  void dispose() {
    _titulo.dispose();
    _enlace.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text('Nuevo anuncio', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(widget.imagen, height: 140, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titulo,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _enlace,
              keyboardType: TextInputType.url,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Enlace al tocar (opcional)',
                hintText: 'https://...',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF39FF14),
          ),
          onPressed: () => Navigator.pop(context, {
            'titulo': _titulo.text.trim().isEmpty
                ? 'Anuncio'
                : _titulo.text.trim(),
            'enlace': _enlace.text.trim(),
          }),
          child: const Text('Publicar', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
