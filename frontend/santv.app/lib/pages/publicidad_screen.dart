import 'dart:io';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter/material.dart';

import '../services/ad_service.dart';

/// Pantalla de "Publicidad" a la que se accede desde el Perfil.
/// Muestra planes de publicidad, documentos/brochures y el
/// portafolio de videos publicitarios ya hechos.
///
/// [esAdmin] controla si se muestran las acciones de administración
/// (subir/eliminar documentos).
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
  late final TabController _tabController =
      TabController(length: 3, vsync: this);

  static const Color neonGreen = Color(0xFF39FF14);

  // Estado de la pestaña Documentos
  List<AdDocumentItem> _documentos = [];
  bool _cargandoDocumentos = true;
  String? _errorDocumentos;

  @override
  void initState() {
    super.initState();
    _cargarDocumentos();
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
      setState(() {
        _documentos = docs;
        _cargandoDocumentos = false;
      });
    } catch (e) {
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
            Tab(text: 'Planes'),
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
      return const Center(
        child: CircularProgressIndicator(color: neonGreen),
      );
    }

    if (_errorDocumentos != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_errorDocumentos!, style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _cargarDocumentos,
              child: const Text('Reintentar', style: TextStyle(color: neonGreen)),
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
                : ListView.builder(
                    itemCount: _documentos.length,
                    itemBuilder: (context, index) {
                      final doc = _documentos[index];
                      return ListTile(
                        leading: const Icon(Icons.picture_as_pdf, color: neonGreen),
                        title: Text(
                          doc.title,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: widget.esAdmin
                            ? IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => _confirmarEliminar(doc.id),
                              )
                            : const Icon(Icons.download, color: Colors.white54),
                        onTap: () {
                          // TODO: abrir doc.mediaUrl (Cloudinary) con url_launcher
                        },
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

  Future<void> _seleccionarYSubirPdf() async {
    final picked = await fp.FilePicker.pickFile(
      type: fp.FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (picked == null) return;

    final titulo = await _pedirTitulo();
    if (titulo == null || titulo.trim().isEmpty) return;

    final exito = await widget.adService.uploadDocument(
      File(picked.path!),
      titulo.trim(),
    );

    if (!mounted) return;

    if (exito) {
      await _cargarDocumentos();
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
        title: const Text('Nombre del documento', style: TextStyle(color: Colors.white)),
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
        title: const Text('Eliminar documento', style: TextStyle(color: Colors.white)),
        content: const Text('¿Seguro que deseas eliminarlo?', style: TextStyle(color: Colors.white54)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final exito = await widget.adService.deleteDocument(id);
              if (!mounted) return;
              if (exito) {
                await _cargarDocumentos();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al eliminar el documento')),
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
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