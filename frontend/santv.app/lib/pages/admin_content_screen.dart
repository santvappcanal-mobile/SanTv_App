import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/admin_service.dart';
import '../models/admin_stats.dart';

/// Pantalla "Contenido": lista completa de videos con editar y eliminar.
/// Carga sus propios datos, así siempre está al día.
class AdminContentScreen extends StatefulWidget {
  const AdminContentScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends State<AdminContentScreen> {
  late final AdminService _adminService;

  static const Color neonGreen = Color(0xFF39FF14);
  static const Color cardBg = Color(0xFF1A1A1A);

  bool _cargando = true;
  String? _error;
  List<TopContentItem> _items = [];

  @override
  void initState() {
    super.initState();
    _adminService = AdminService(authService: widget.authService);
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? 'Contenido actualizado'
              : (result.errorMessage ?? 'Error al actualizar'),
        ),
      ),
    );
    if (result.success) _cargar();
  }

  Future<void> _eliminar(TopContentItem item) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        title: const Text(
          'Eliminar contenido',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Seguro que quieres eliminar "${item.title}"? '
          'Esta acción no se puede deshacer.',
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
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    final result = await _adminService.deleteContent(item.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? 'Contenido eliminado'
              : (result.errorMessage ?? 'Error al eliminar'),
        ),
      ),
    );
    if (result.success) _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Todos mis videos (${_items.length})',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargando ? null : _cargar,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator(color: neonGreen));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: Colors.redAccent, size: 40),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _cargar,
                style: ElevatedButton.styleFrom(backgroundColor: neonGreen),
                child: const Text('Reintentar',
                    style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return const Center(
        child: Text(
          'Aún no hay videos subidos',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return RefreshIndicator(
      color: neonGreen,
      onRefresh: _cargar,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (_, i) => _buildCard(_items[i]),
      ),
    );
  }

  Widget _buildCard(TopContentItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: item.thumbnailUrl.isNotEmpty
                ? Image.network(
                    item.thumbnailUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.type,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.remove_red_eye, color: neonGreen, size: 16),
          const SizedBox(width: 4),
          Text('${item.views}', style: const TextStyle(color: neonGreen)),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
            tooltip: 'Editar',
            visualDensity: VisualDensity.compact,
            onPressed: () => _editar(item),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Colors.redAccent, size: 20),
            tooltip: 'Eliminar',
            visualDensity: VisualDensity.compact,
            onPressed: () => _eliminar(item),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.white12,
      child: const Icon(Icons.movie, color: Colors.white38, size: 20),
    );
  }
}

/// Diálogo de edición (título obligatorio, descripción opcional).
/// Público para que también lo use el Top 5 del dashboard.
class EditContentDialog extends StatefulWidget {
  const EditContentDialog({super.key, required this.item});

  final TopContentItem item;

  @override
  State<EditContentDialog> createState() => _EditContentDialogState();
}

class _EditContentDialogState extends State<EditContentDialog> {
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color cardBg = Color(0xFF1A1A1A);

  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.item.title);
    _descCtrl = TextEditingController(text: widget.item.description);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    final title = _titleCtrl.text.trim();
    final description = _descCtrl.text.trim();

    if (title.isEmpty) {
      setState(() => _validationError = 'El título no puede estar vacío');
      return;
    }

    Navigator.pop(context, {'title': title, 'description': description});
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white24),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: neonGreen),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: cardBg,
      title: const Text(
        'Editar contenido',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(color: Colors.white),
              cursorColor: neonGreen,
              decoration: _decoration('Título'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              cursorColor: neonGreen,
              decoration: _decoration('Descripción (opcional)'),
            ),
            if (_validationError != null) ...[
              const SizedBox(height: 12),
              Text(
                _validationError!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar',
              style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: _guardar,
          style: ElevatedButton.styleFrom(backgroundColor: neonGreen),
          child: const Text('Guardar', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}