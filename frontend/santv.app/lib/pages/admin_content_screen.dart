import 'package:flutter/material.dart';
import '../models/admin_stats.dart';
import '../services/admin_service.dart';
import '../services/auth_service.dart';
import '../widgets/admin/admin_app_bar.dart';
import '../widgets/admin/admin_content_list.dart';
import '../widgets/admin/edit_content_dialog.dart';
import '../widgets/ads/confirm_delete_dialog.dart';

// El dashboard sigue importando EditContentDialog desde esta pantalla.
export '../widgets/admin/edit_content_dialog.dart' show EditContentDialog;

/// Pantalla "Contenido": lista completa de videos con editar y eliminar.
/// Carga sus propios datos, así siempre está al día.
class AdminContentScreen extends StatefulWidget {
  const AdminContentScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends State<AdminContentScreen> {
  late final _adminService = AdminService(authService: widget.authService);
  bool _cargando = true;
  String? _error;
  List<TopContentItem> _items = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    final result = await _adminService.getAllContent();
    if (!mounted) return;
    setState(() {
      _cargando = false;
      if (result.success) {
        _items = result.items;
      } else {
        _error = result.errorMessage ?? 'No se pudo cargar el contenido';
      }
    });
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _editar(TopContentItem item) async {
    final data = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => EditContentDialog(item: item),
    );
    if (data == null) return;
    final result = await _adminService.updateContent(
      id: item.id,
      title: data['title']!,
      description: data['description']!,
    );
    if (!mounted) return;
    _mensaje(
      result.success
          ? 'Contenido actualizado'
          : (result.errorMessage ?? 'Error al actualizar'),
    );
    if (result.success) _cargar();
  }

  Future<void> _eliminar(TopContentItem item) async {
    final confirmar = await ConfirmDeleteDialog.show(
      context,
      title: 'Eliminar contenido',
      message:
          '¿Seguro que quieres eliminar "${item.title}"? '
          'Esta acción no se puede deshacer.',
    );
    if (!confirmar) return;
    final result = await _adminService.deleteContent(item.id);
    if (!mounted) return;
    _mensaje(
      result.success
          ? 'Contenido eliminado'
          : (result.errorMessage ?? 'Error al eliminar'),
    );
    if (result.success) _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AdminAppBar(
        title: 'Todos mis videos (${_items.length})',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargando ? null : _cargar,
          ),
        ],
      ),
      body: AdminContentList(
        loading: _cargando,
        error: _error,
        items: _items,
        onRefresh: _cargar,
        onEdit: _editar,
        onDelete: _eliminar,
      ),
    );
  }
}