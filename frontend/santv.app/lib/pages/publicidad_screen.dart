import 'package:flutter/material.dart';
import '../services/ad_service.dart';
import '../widgets/publicidad/publicidad_controller.dart';
import '../widgets/publicidad/references_actions_mixin.dart';
import '../widgets/publicidad/documents_actions_mixin.dart';
import '../widgets/publicidad/gallery_actions_mixin.dart';
import '../widgets/publicidad/references_tab.dart';
import '../widgets/publicidad/documents_tab.dart';
import '../widgets/publicidad/portfolio_tab.dart';
import 'ad_order_form_screen.dart';
import 'ad_orders_screen.dart';

/// [esAdmin] controla si se muestran las acciones de administración
/// (subir/eliminar documentos, videos de referencias e imágenes del portafolio).
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
    with
        SingleTickerProviderStateMixin,
        ReferencesActionsMixin<PublicidadScreen>,
        DocumentsActionsMixin<PublicidadScreen>,
        GalleryActionsMixin<PublicidadScreen> {
  static const Color neonGreen = Color(0xFF39FF14);

  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
  );
  late final PublicidadController _c;

  @override
  AdService get adService => widget.adService;

  @override
  PublicidadController get publicidad => _c;

  @override
  void initState() {
    super.initState();
    _c = PublicidadController(adService: widget.adService)..cargarTodo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _c.dispose();
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
        actions: [
          IconButton(
            tooltip: widget.esAdmin ? 'Solicitudes de pauta' : 'Mis pautas',
            icon: const Icon(Icons.receipt_long_outlined, color: neonGreen),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdOrdersScreen(
                  authService: widget.adService.authService,
                  esAdmin: widget.esAdmin,
                ),
              ),
            ),
          ),
        ],
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
      // El botón "Quiero pautar" lo ven tanto usuarios como administradores.
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: neonGreen,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.campaign_outlined),
        label: const Text('Quiero pautar'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AdOrderFormScreen(authService: widget.adService.authService),
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: _c,
        builder: (context, _) => TabBarView(
          controller: _tabController,
          children: [
            ReferencesTab(
              state: _c.referencias,
              esAdmin: widget.esAdmin,
              onReload: _c.cargarReferencias,
              onAdd: seleccionarYSubirVideo,
              onOpen: abrirReferencia,
              onEdit: editarReferencia,
              onDelete: eliminarReferencia,
            ),
            DocumentsTab(
              state: _c.documentos,
              esAdmin: widget.esAdmin,
              onReload: _c.cargarDocumentos,
              onUpload: seleccionarYSubirPdf,
              onOpen: abrirDocumento,
              onDelete: eliminarDocumento,
            ),
            PortfolioTab(
              state: _c.galeria,
              esAdmin: widget.esAdmin,
              onReload: _c.cargarGaleria,
              onUpload: seleccionarYSubirImagenes,
              onEdit: editarDescripcion,
              onDelete: eliminarImagen,
            ),
          ],
        ),
      ),
    );
  }
}