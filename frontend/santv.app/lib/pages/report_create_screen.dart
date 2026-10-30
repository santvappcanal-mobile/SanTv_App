import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../models/report.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';

/// Crear un reporte nuevo o, si recibe [report], editar uno propio.
class ReportCreateScreen extends StatefulWidget {
  const ReportCreateScreen({super.key, required this.authService, this.report});

  final AuthService authService;

  /// Si viene, la pantalla funciona en modo edición.
  final Report? report;

  @override
  State<ReportCreateScreen> createState() => _ReportCreateScreenState();
}

class _ReportCreateScreenState extends State<ReportCreateScreen> {
  static const _neon = Color(0xFF39FF14);
  static const _categories = ['Noticias', 'Deportes', 'Educación', 'Comunidad'];

  late final ReportService _service = ReportService(widget.authService);
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  File? _image;
  String _category = 'Noticias';
  Position? _position;
  String? _locationError;
  bool _locating = false;
  bool _sending = false;

  bool get _isEdit => widget.report != null;

  @override
  void initState() {
    super.initState();
    final r = widget.report;
    if (r != null) {
      _titleCtrl.text = r.title;
      _descCtrl.text = r.description;
      _addressCtrl.text = r.address;
      _category = _categories.contains(r.category) ? r.category : 'Noticias';
    } else {
      _getLocation();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() {
      _locating = true;
      _locationError = null;
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw 'Activa el GPS de tu teléfono para ubicar el reporte.';
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw 'Necesitamos el permiso de ubicación para ubicar el reporte.';
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'El permiso de ubicación está bloqueado. Actívalo en los ajustes de la app.';
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      if (!mounted) return;
      setState(() => _position = pos);
    } catch (e) {
      if (!mounted) return;
      setState(() => _locationError = e is String ? e : 'No se pudo obtener tu ubicación.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (picked != null && mounted) setState(() => _image = File(picked.path));
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: _neon),
              title: const Text('Tomar foto', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: _neon),
              title: const Text('Elegir de la galería', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Modo edición: solo se guardan los textos y la categoría.
    if (_isEdit) {
      final report = widget.report!;
      setState(() => _sending = true);
      try {
        await _service.update(
          report.id,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          category: _category,
          address: _addressCtrl.text.trim(),
        );
        if (!mounted) return;
        _snack(report.isRejected
            ? 'Reporte actualizado y enviado de nuevo a revisión'
            : 'Reporte actualizado');
        Navigator.pop(context, true);
      } on ReportException catch (e) {
        _snack(e.message);
      } finally {
        if (mounted) setState(() => _sending = false);
      }
      return;
    }

    if (_image == null) {
      _snack('Agrega una foto del suceso.');
      return;
    }
    if (_position == null) {
      _snack('Todavía no tenemos tu ubicación.');
      return;
    }

    setState(() => _sending = true);
    try {
      await _service.createReport(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _category,
        latitude: _position!.latitude,
        longitude: _position!.longitude,
        address: _addressCtrl.text.trim(),
        image: _image!,
      );
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('¡Reporte enviado!', style: TextStyle(color: Colors.white)),
          content: const Text(
            'El equipo de SAN TV lo revisará. Si lo aprueban, saldrá en Noticias '
            'con tu nombre y ganarás puntos.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido', style: TextStyle(color: _neon)),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } on ReportException catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  InputDecoration _decoration(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.white60),
        hintStyle: const TextStyle(color: Colors.white30),
        filled: true,
        fillColor: const Color(0xFF141414),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _neon),
        ),
      );

  /// Aviso del modo edición según el estado del reporte.
  String? get _editNotice {
    final r = widget.report;
    if (r == null) return null;
    if (r.isApproved) {
      return 'Este reporte ya está publicado: los cambios también se verán en Noticias.';
    }
    if (r.isRejected) {
      return 'Al guardar, tu reporte volverá a revisión del equipo.';
    }
    return null;
  }

  Widget _buildPhoto() {
    if (_isEdit) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: widget.report!.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                height: 200,
                color: Colors.black26,
                child: const Icon(Icons.broken_image, color: Colors.white38),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'La foto y la ubicación no se pueden cambiar.',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _sending ? null : _showImageOptions,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        clipBehavior: Clip.antiAlias,
        child: _image == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, color: _neon, size: 40),
                  SizedBox(height: 8),
                  Text('Agregar foto', style: TextStyle(color: Colors.white70)),
                ],
              )
            : Image.file(_image!, fit: BoxFit.cover, width: double.infinity),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notice = _editNotice;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0B),
        foregroundColor: Colors.white,
        title: Text(_isEdit ? 'Editar reporte' : 'Reportar una noticia'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              _isEdit
                  ? 'Corrige los datos de tu reporte.'
                  : 'Cuéntanos qué está pasando en tu comunidad.',
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            if (notice != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _neon.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: _neon, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(notice,
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildPhoto(),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    style: const TextStyle(color: Colors.white),
                    maxLength: 120,
                    decoration: _decoration('Título', hint: 'Ej: Derrumbe en la vía principal'),
                    validator: (v) =>
                        (v == null || v.trim().length < 5) ? 'Mínimo 5 caracteres' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descCtrl,
                    style: const TextStyle(color: Colors.white),
                    maxLength: 1000,
                    maxLines: 4,
                    decoration: _decoration('¿Qué pasó?', hint: 'Describe lo que viste'),
                    validator: (v) =>
                        (v == null || v.trim().length < 10) ? 'Cuéntanos un poco más (mín. 10)' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _addressCtrl,
                    style: const TextStyle(color: Colors.white),
                    maxLength: 200,
                    decoration: _decoration('Referencia del lugar (opcional)',
                        hint: 'Barrio, vereda o punto de referencia'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text('Categoría', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _categories.map((c) {
                final selected = c == _category;
                return ChoiceChip(
                  label: Text(c),
                  selected: selected,
                  onSelected: (_) => setState(() => _category = c),
                  selectedColor: _neon,
                  backgroundColor: const Color(0xFF141414),
                  labelStyle: TextStyle(color: selected ? Colors.black : Colors.white70),
                  side: BorderSide.none,
                );
              }).toList(),
            ),
            if (!_isEdit) ...[
              const SizedBox(height: 16),
              _LocationCard(
                locating: _locating,
                position: _position,
                error: _locationError,
                onRetry: _getLocation,
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _sending ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _neon,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _sending
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                      )
                    : Text(_isEdit ? 'Guardar cambios' : 'Enviar reporte',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.locating,
    required this.position,
    required this.error,
    required this.onRetry,
  });

  final bool locating;
  final Position? position;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    late final IconData icon;
    late final Color color;
    late final String text;

    if (locating) {
      icon = Icons.my_location;
      color = Colors.white54;
      text = 'Obteniendo tu ubicación...';
    } else if (position != null) {
      icon = Icons.location_on;
      color = const Color(0xFF39FF14);
      text = 'Ubicación lista (${position!.latitude.toStringAsFixed(4)}, '
          '${position!.longitude.toStringAsFixed(4)})';
    } else {
      icon = Icons.location_off;
      color = Colors.redAccent;
      text = error ?? 'No se pudo obtener tu ubicación.';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70))),
          if (!locating && position == null)
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}