import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/admin_service.dart';
import '../models/admin_stats.dart';
import '../widgets/admin_dashboard/admin_dashboard_widgets.dart';
import 'admin_add_youtube_screen.dart';
import 'admin_users_screen.dart';
import 'admin_content_screen.dart';
import 'admin_ads_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key, required this.authService});

  final AuthService authService;

  static const Color neonGreen = kNeonGreen;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final AdminService _admin;
  bool _cargando = true;
  String? _error;
  AdminStats? _stats;

  AuthService get _auth => widget.authService;

  @override
  void initState() {
    super.initState();
    _admin = AdminService(authService: _auth);
    _cargarStats();
  }

  Future<void> _cargarStats() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    final r = await _admin.getDashboardStats();
    if (!mounted) return;
    setState(() {
      _cargando = false;
      if (r.success) {
        _stats = r.stats;
      } else {
        _error = r.errorMessage;
      }
    });
  }

  Future<void> _ir(Widget pantalla) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
    if (mounted) _cargarStats();
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _editar(TopContentItem item) async {
    final data = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => EditContentDialog(item: item),
    );
    if (data == null) return;
    final r = await _admin.updateContent(
      id: item.id,
      title: data['title']!,
      description: data['description']!,
    );
    if (!mounted) return;
    _snack(r.success ? 'Contenido actualizado' : (r.errorMessage ?? 'Error'));
    if (r.success) _cargarStats();
  }

  Future<void> _eliminar(TopContentItem item) async {
    if (!await confirmarEliminarContenido(context, item.title)) return;
    final r = await _admin.deleteContent(item.id);
    if (!mounted) return;
    _snack(r.success ? 'Contenido eliminado' : (r.errorMessage ?? 'Error'));
    if (r.success) _cargarStats();
  }

  Widget _body() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator(color: kNeonGreen));
    }
    if (_error != null) {
      return ErrorRetryView(message: _error!, onRetry: _cargarStats);
    }
    return DashboardBody(
      stats: _stats!,
      onRefresh: _cargarStats,
      onUsuarios: () => _ir(AdminUsersScreen(authService: _auth)),
      onContenido: () => _ir(AdminContentScreen(authService: _auth)),
      onAnuncios: () => _ir(AdminAdsScreen(authService: _auth)),
      onEdit: _editar,
      onDelete: _eliminar,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScreenBg,
      appBar: DashboardAppBar(onRefresh: _cargando ? null : _cargarStats),
      body: _body(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kNeonGreen,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('Agregar video', style: TextStyle(color: Colors.black)),
        onPressed: () => _ir(AdminAddYoutubeScreen(authService: _auth)),
      ),
    );
  }
}