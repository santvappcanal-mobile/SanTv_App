import 'package:flutter/material.dart';

/// Pantalla de "Publicidad" a la que se accede desde el Perfil.
/// Muestra planes de publicidad, documentos/brochures y el
/// portafolio de videos publicitarios ya hechos.
///
/// [esAdmin] controla si se muestran las acciones de administración
/// (subir/eliminar documentos). Por ahora la subida real de PDFs se
/// hace desde Postman/backend, no desde la app.
class PublicidadScreen extends StatefulWidget {
  const PublicidadScreen({
    super.key,
    required this.esAdmin,
    this.adminToken,
  });

  final bool esAdmin;
  final String? adminToken;

  @override
  State<PublicidadScreen> createState() => _PublicidadScreenState();
}

class _PublicidadScreenState extends State<PublicidadScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 3, vsync: this);

  static const Color neonGreen = Color(0xFF39FF14);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    // TODO: listar documentos desde el backend
    // TODO: si widget.esAdmin, mostrar acción de subir/eliminar
    return const Center(
      child: Text(
        'Documentos y brochures (próximamente)',
        style: TextStyle(color: Colors.white54),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Pestaña Portafolio: se conecta a la colección Ad existente (type: video)
  // ---------------------------------------------------------------
  Widget _buildPortafolioTab() {
    // TODO: conectar con GET /api/ads?type=video
    return const Center(
      child: Text(
        'Portafolio de videos publicitarios (próximamente)',
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}