import 'dart:io';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Ocultamos AdDocumentItem de ad.dart para evitar el conflicto
import '../models/ad.dart' hide AdDocumentItem;
import '../models/ad_document_item.dart';
import '../models/gallery_item.dart';

import '../services/ad_service.dart';
import '../widgets/common/gallery_grid.dart';
import '../widgets/common/pdf_document_card.dart';
import 'pdf_viewer_page.dart';


/// [esAdmin] controla si se muestran las acciones de administración
/// (subir/eliminar documentos e imágenes).
/// [adService] es la instancia ya creada con el AuthService del usuario
/// (mismo patrón que usan las demás pantallas para llamadas autenticadas).
class PublicidadScreen extends StatefulWidget {
  const PublicidadScreen({
    super.key,
    required this.esAdmin,
    required this.adService,
  });

  final bool esAdmin;
  final AdService adService;

  @override
  State<PublicidadScreen> createState() => _PublicidadScreenState();
}

class _PublicidadScreenState extends State<PublicidadScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
  );

  static const Color neonGreen = Color(0xFF39FF14);

  // Estado de la pestaña Documentos
  List<AdDocumentItem> _documentos = [];
  bool _cargandoDocumentos = true;
  String? _errorDocumentos;

  // Estado de la pestaña Portafolio (galería)
  List<GalleryItem> _galeria = [];
  bool _cargandoGaleria = true;
  bool _subiendoGaleria = false;
  String? _errorGaleria;

  @override
  void initState() {
    super.initState();
    _cargarDocumentos();
    _cargarGaleria();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDocumentos() async {
    setState(() {
      _cargandoDocumentos = true;
      _errorDocumentos = null;
    });
    try {
      final docs = await widget.adService.getDocuments();
      if (!mounted) return;
      setState(() {
        _documentos = docs;
        _cargandoDocumentos = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorDocumentos = 'Error al cargar documentos';
        _cargandoDocumentos = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0B),
        title: const Text('Publicidad', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: neonGreen,
          labelColor: neonGreen,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Referencias'),
            Tab(text: 'Documentos'),
            Tab(text: 'Portafolio'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlanesTab(),
          _buildDocumentosTab(),
          _buildPortafolioTab(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Pestaña Planes: datos fijos en el código (sin base de datos nueva)
  // ---------------------------------------------------------------
  Widget _buildPlanesTab() {
    // TODO: reemplazar por los planes fijos definidos en el código
    return const Center(
      child: Text(
        'Planes de publicidad (próximamente)',
        style: TextStyle(color: Colors.white54),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Pestaña Documentos: PDFs/brochures vía Cloudinary
  // Solo el admin puede subir/eliminar; usuarios normales solo ven/descargan
  // ---------------------------------------------------------------
  Widget _buildDocumentosTab() {
    if (_cargandoDocumentos) {
      return const Center(child: CircularProgressIndicator(color: neonGreen));
    }

    if (_errorDocumentos != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorDocumentos!,
              style: const TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _cargarDocumentos,
              child: const Text(
                'Reintentar',
                style: TextStyle(color: neonGreen),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarDocumentos,
      color: neonGreen,
      child: Column(
        children: [
          if (widget.esAdmin) _buildBotonSubir(),
          Expanded(
            child: _documentos.isEmpty
                ? ListView(
                    // ListView para que el RefreshIndicator funcione aun vacío
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Text(
                          'No hay documentos aún',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: _documentos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doc = _documentos[index];
                      return SizedBox(
                        height: 220, // rectángulo de ancho completo
                        child: PdfDocumentCard(
                          titulo: doc.title,
                          url: doc.mediaUrl,
                          onDelete: widget.esAdmin
                              ? () => _confirmarEliminar(doc.id)
                              : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PdfViewerPage(
                                  url: doc.mediaUrl,
                                  titulo: doc.title,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonSubir() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: neonGreen),
        icon: const Icon(Icons.upload_file, color: Colors.black),
        label: const Text('Subir PDF', style: TextStyle(color: Colors.black)),
        onPressed: _seleccionarYSubirPdf,
      ),
    );
  }

  /// Flujo: elegir PDF -> vista previa -> confirmar -> nombre -> subir.
  Future<void> _seleccionarYSubirPdf() async {
    final picked = await fp.FilePicker.pickFile(
      type: fp.FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (picked == null || picked.path == null) return;
    if (!mounted) return;

    final file = File(picked.path!);

    // Vista previa antes de subir
    final confirmar = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PdfViewerPage(file: file, titulo: picked.name, confirmar: true),
      ),
    );
    if (confirmar != true || !mounted) return;

    final titulo = await _pedirTitulo();
    if (titulo == null || titulo.trim().isEmpty) return;

    final exito = await widget.adService.uploadDocument(file, titulo.trim());

    if (!mounted) return;

    if (exito) {
      await _cargarDocumentos();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Documento subido correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al subir el documento')),
      );
    }
  }

  Future<String?> _pedirTitulo() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Nombre del documento',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Ej. Reseña SanTv 2026',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Subir', style: TextStyle(color: neonGreen)),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Eliminar documento',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Seguro que deseas eliminarlo?',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final exito = await widget.adService.deleteDocument(id);
              if (!mounted) return;
              if (exito) {
                await _cargarDocumentos();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error al eliminar el documento'),
                  ),
                );
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Pestaña Portafolio: galería de imágenes (Ad con type: 'gallery')
  // Solo el admin puede subir/eliminar; los demás solo ven.
  // ---------------------------------------------------------------
  Future<void> _cargarGaleria() async {
    setState(() {
      _cargandoGaleria = true;
      _errorGaleria = null;
    });
    try {
      final items = await widget.adService.getGallery();
      if (!mounted) return;
      setState(() {
        _galeria = items;
        _cargandoGaleria = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorGaleria = 'Error al cargar la galería';
        _cargandoGaleria = false;
      });
    }
  }

  Widget _buildPortafolioTab() {
    if (_cargandoGaleria) {
      return const Center(child: CircularProgressIndicator(color: neonGreen));
    }

    if (_errorGaleria != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorGaleria!,
              style: const TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _cargarGaleria,
              child: const Text(
                'Reintentar',
                style: TextStyle(color: neonGreen),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarGaleria,
      color: neonGreen,
      child: Column(
        children: [
          if (widget.esAdmin) _buildBotonSubirImagenes(),
          if (_subiendoGaleria)
            const LinearProgressIndicator(
              color: neonGreen,
              backgroundColor: Colors.white12,
            ),
          Expanded(
            child: _galeria.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Text(
                          'No hay imágenes aún',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ],
                  )
                : GalleryGrid(
                    items: _galeria,
                    onDelete: widget.esAdmin
                        ? (item) => _confirmarEliminarImagen(item.id)
                        : null,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonSubirImagenes() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: neonGreen),
        icon: const Icon(Icons.add_photo_alternate, color: Colors.black),
        label: const Text(
          'Subir imágenes',
          style: TextStyle(color: Colors.black),
        ),
        onPressed: _subiendoGaleria ? null : _seleccionarYSubirImagenes,
      ),
    );
  }

  /// Flujo: elegir varias imágenes de la galería -> subir -> recargar.
  Future<void> _seleccionarYSubirImagenes() async {
    final picked = await ImagePicker().pickMultiImage(
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (picked.isEmpty || !mounted) return;

    setState(() => _subiendoGaleria = true);

    final error = await widget.adService.uploadGalleryImages(
      picked.map((x) => File(x.path)).toList(),
    );

    if (!mounted) return;
    setState(() => _subiendoGaleria = false);

    if (error == null) {
      await _cargarGaleria();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${picked.length} imagen(es) subida(s)')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  void _confirmarEliminarImagen(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Eliminar imagen',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Seguro que deseas eliminarla?',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final exito = await widget.adService.eliminarAd(id);
              if (!mounted) return;
              if (exito) {
                await _cargarGaleria();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error al eliminar la imagen'),
                  ),
                );
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}