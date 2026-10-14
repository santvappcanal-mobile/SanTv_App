import 'dart:io';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter/material.dart';

// Ocultamos AdDocumentItem de ad.dart para evitar el conflicto
import '../models/ad.dart' hide AdDocumentItem;
import '../models/ad_document_item.dart';
import '../models/reference_video_item.dart';

import '../services/ad_service.dart';
import '../widgets/common/pdf_document_card.dart';
import 'pdf_viewer_page.dart';
import 'reference_video_player_page.dart';

/// [esAdmin] controla si se muestran las acciones de administración
/// (subir/eliminar documentos y videos de referencias).
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

  /// Límite del plan gratuito de Cloudinary para videos (100 MB).
  static const int _maxVideoBytes = 100 * 1024 * 1024;

  // Estado de la pestaña Documentos
  List<AdDocumentItem> _documentos = [];
  bool _cargandoDocumentos = true;
  String? _errorDocumentos;

  // Estado de la pestaña Referencias
  List<ReferenceVideoItem> _referencias = [];
  bool _cargandoReferencias = true;
  String? _errorReferencias;

  @override
  void initState() {
    super.initState();
    _cargarDocumentos();
    _cargarReferencias();
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

  Future<void> _cargarReferencias() async {
    setState(() {
      _cargandoReferencias = true;
      _errorReferencias = null;
    });
    try {
      final items = await widget.adService.getReferences();
      if (!mounted) return;
      setState(() {
        _referencias = items;
        _cargandoReferencias = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorReferencias = 'Error al cargar las referencias';
        _cargandoReferencias = false;
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
          _buildReferenciasTab(),
          _buildDocumentosTab(),
          _buildPortafolioTab(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Pestaña Referencias: videos subidos a Cloudinary
  // Solo el admin/editor puede subir/eliminar; todos pueden verlos
  // ---------------------------------------------------------------
  Widget _buildReferenciasTab() {
    if (_cargandoReferencias) {
      return const Center(child: CircularProgressIndicator(color: neonGreen));
    }

    if (_errorReferencias != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorReferencias!,
              style: const TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _cargarReferencias,
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
      onRefresh: _cargarReferencias,
      color: neonGreen,
      child: Column(
        children: [
          if (widget.esAdmin) _buildBotonAgregarVideo(),
          Expanded(
            child: _referencias.isEmpty
                ? ListView(
                    // ListView para que el RefreshIndicator funcione aun vacío
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Text(
                          'No hay videos de referencia aún',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: _referencias.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _buildReferenciaCard(_referencias[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonAgregarVideo() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: neonGreen),
        icon: const Icon(Icons.video_call, color: Colors.black),
        label: const Text(
          'Agregar video',
          style: TextStyle(color: Colors.black),
        ),
        onPressed: _seleccionarYSubirVideo,
      ),
    );
  }

  Widget _buildReferenciaCard(ReferenceVideoItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReferenceVideoPlayerPage(
              url: item.mediaUrl,
              titulo: item.title,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Miniatura (fotograma del video) con respaldo si falla
              Image.network(
                item.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF1A1A1A),
                  child: const Icon(
                    Icons.videocam_rounded,
                    color: Colors.white24,
                    size: 56,
                  ),
                ),
              ),
              // Degradado inferior para que se lea el título
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
              // Botón de play al centro
              Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: neonGreen, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: neonGreen,
                    size: 36,
                  ),
                ),
              ),
              // Título y descripción
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Editar y eliminar (solo admin/editor)
              if (widget.esAdmin)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => _editarReferencia(item),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            color: neonGreen,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _confirmarEliminarReferencia(item.id),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Flujo: elegir video -> validar tamaño -> nombre -> subir con indicador.
  Future<void> _seleccionarYSubirVideo() async {
    final picked = await fp.FilePicker.pickFile(type: fp.FileType.video);
    if (picked == null || picked.path == null) return;
    if (!mounted) return;

    final file = File(picked.path!);

    final bytes = await file.length();
    if (bytes > _maxVideoBytes) {
      if (!mounted) return;
      final mb = (bytes / (1024 * 1024)).toStringAsFixed(1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'El video pesa $mb MB y el máximo permitido es 100 MB. '
            'Comprímelo e inténtalo de nuevo.',
          ),
        ),
      );
      return;
    }

    final titulo = await _pedirTitulo(
      titulo: 'Nombre del video',
      hint: 'Ej. Spot restaurante La Plaza',
    );
    if (titulo == null || titulo.trim().isEmpty) return;
    if (!mounted) return;

    // Diálogo de "subiendo..." que no se puede cerrar tocando afuera
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: const AlertDialog(
          backgroundColor: Color(0xFF1A1A1A),
          content: Row(
            children: [
              CircularProgressIndicator(color: neonGreen),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  'Subiendo video, no cierres la app...',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final error = await widget.adService.uploadReferenceVideo(
      file,
      titulo.trim(),
    );

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // cierra el diálogo

    if (error == null) {
      await _cargarReferencias();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video subido correctamente')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  /// Diálogo para corregir el título y la descripción de un video.
  Future<void> _editarReferencia(ReferenceVideoItem item) async {
    final tituloCtrl = TextEditingController(text: item.title);
    final descCtrl = TextEditingController(text: item.description);

    final guardar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Editar video',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tituloCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Título',
                  labelStyle: TextStyle(color: Colors.white54),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar', style: TextStyle(color: neonGreen)),
          ),
        ],
      ),
    );

    final nuevoTitulo = tituloCtrl.text.trim();
    final nuevaDescripcion = descCtrl.text.trim();

    if (guardar != true || !mounted) return;

    if (nuevoTitulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título no puede estar vacío')),
      );
      return;
    }

    final error = await widget.adService.updateReference(
      item.id,
      title: nuevoTitulo,
      description: nuevaDescripcion,
    );

    if (!mounted) return;

    if (error == null) {
      await _cargarReferencias();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video actualizado')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _confirmarEliminarReferencia(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Eliminar video',
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
              final exito = await widget.adService.deleteReference(id);
              if (!mounted) return;
              if (exito) {
                await _cargarReferencias();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al eliminar el video')),
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

    final titulo = await _pedirTitulo(
      titulo: 'Nombre del documento',
      hint: 'Ej. Reseña SanTv 2026',
    );
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

  /// Diálogo genérico para pedir el nombre de un documento o video.
  Future<String?> _pedirTitulo({required String titulo, required String hint}) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(titulo, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
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
  // Pestaña Portafolio: se conecta a la colección Ad existente (type: video)
  // ---------------------------------------------------------------
  Widget _buildPortafolioTab() {
    // TODO: conectar con widget.adService.getPortfolio()
    return const Center(
      child: Text(
        'Portafolio de videos publicitarios (próximamente)',
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}