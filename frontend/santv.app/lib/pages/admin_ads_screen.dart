import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ad_service.dart';
import '../services/auth_service.dart';
import '../widgets/admin/admin_app_bar.dart';
import '../widgets/ads/admin_ads_list.dart';
import '../widgets/ads/confirm_delete_dialog.dart';
import '../widgets/ads/new_ad_dialog.dart';
import '../widgets/ads/upload_ad_fab.dart';

class AdminAdsScreen extends StatefulWidget {
  const AdminAdsScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<AdminAdsScreen> createState() => _AdminAdsScreenState();
}

class _AdminAdsScreenState extends State<AdminAdsScreen> {
  late final _adService = AdService(authService: widget.authService);
  List<Map<String, dynamic>> _ads = [];
  bool _cargando = true;
  String? _error;

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
    try {
      final todos = await _adService.listarAdsAdmin();
      // Los PDF legales se manejan en Publicidad > Documentos
      _ads = todos.where((a) => a['type'] != 'document').toList();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _cargando = false);
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
      builder: (_) => NewAdDialog(imagen: File(picked.path)),
    );
    if (datos == null || !mounted) return;
    _mensaje('Subiendo anuncio...');
    final error = await _adService.subirAnuncioImagen(
      imagen: File(picked.path),
      titulo: datos['titulo']!,
      enlace: datos['enlace'],
    );
    if (!mounted) return;
    _mensaje(error ?? 'Anuncio publicado');
    if (error == null) _cargar();
  }

  Future<void> _cambiarEstado(Map<String, dynamic> ad, bool activo) async {
    final ok = await _adService.cambiarEstadoAd(ad['_id'].toString(), activo);
    if (!mounted) return;
    if (ok) setState(() => ad['isActive'] = activo);
    if (!ok) _mensaje('No se pudo cambiar el estado');
  }

  Future<void> _eliminar(Map<String, dynamic> ad) async {
    final confirmar = await ConfirmDeleteDialog.show(
      context,
      title: 'Eliminar anuncio',
      message: '¿Eliminar "${ad['title']}"? No se puede deshacer.',
    );
    if (!confirmar) return;
    final ok = await _adService.eliminarAd(ad['_id'].toString());
    if (!mounted) return;
    _mensaje(ok ? 'Anuncio eliminado' : 'No se pudo eliminar');
    if (ok) _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AdminAppBar(
        title: 'Anuncios',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargando ? null : _cargar,
          ),
        ],
      ),
      floatingActionButton: UploadAdFab(onPressed: _nuevoAnuncio),
      body: AdminAdsList(
        loading: _cargando,
        error: _error,
        ads: _ads,
        onRefresh: _cargar,
        onToggle: _cambiarEstado,
        onDelete: _eliminar,
      ),
    );
  }
}