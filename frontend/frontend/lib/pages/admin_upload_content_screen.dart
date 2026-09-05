import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/content_services.dart';

class AdminUploadContentScreen extends StatefulWidget {
  const AdminUploadContentScreen({super.key, required this.authService});

  final AuthService authService;

  static const Color neonGreen = Color(0xFF39FF14);

  @override
  State<AdminUploadContentScreen> createState() =>
      _AdminUploadContentScreenState();
}

class _AdminUploadContentScreenState extends State<AdminUploadContentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ContentService _contentService;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _genresController = TextEditingController();
  final _thumbnailUrlController = TextEditingController();
  final _durationController = TextEditingController();
  final _releaseYearController = TextEditingController();

  String _type = 'movie';
  bool _isPremium = false;
  File? _videoFile;
  String? _videoFileName;
  bool _subiendo = false;
  String? _mensaje;
  bool _mensajeEsError = false;

  static const Color neonGreen = AdminUploadContentScreen.neonGreen;

  @override
  void initState() {
    super.initState();
    _contentService = ContentService(authService: widget.authService);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _genresController.dispose();
    _thumbnailUrlController.dispose();
    _durationController.dispose();
    _releaseYearController.dispose();
    super.dispose();
  }

  Future<void> _elegirVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _videoFile = File(result.files.single.path!);
        _videoFileName = result.files.single.name;
      });
    }
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_videoFile == null) {
      setState(() {
        _mensaje = 'Debes seleccionar un archivo de video.';
        _mensajeEsError = true;
      });
      return;
    }

    setState(() {
      _subiendo = true;
      _mensaje = null;
    });

    final result = await _contentService.subirVideo(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _type,
      videoFile: _videoFile!,
      genres: _genresController.text.trim(),
      thumbnailUrl: _thumbnailUrlController.text.trim(),
      duration: int.tryParse(_durationController.text.trim()),
      releaseYear: int.tryParse(_releaseYearController.text.trim()),
      isPremium: _isPremium,
    );

    if (!mounted) return;

    setState(() {
      _subiendo = false;
      _mensaje = result.success
          ? 'Video subido correctamente.'
          : (result.errorMessage ?? 'Ocurrió un error al subir el video.');
      _mensajeEsError = !result.success;
    });

    if (result.success) {
      _formKey.currentState!.reset();
      _titleController.clear();
      _descriptionController.clear();
      _genresController.clear();
      _thumbnailUrlController.clear();
      _durationController.clear();
      _releaseYearController.clear();
      setState(() {
        _videoFile = null;
        _videoFileName = null;
        _type = 'movie';
        _isPremium = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Agregar contenido', style: TextStyle(color: Colors.white)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildTextField(_titleController, 'Título', requerido: true),
            const SizedBox(height: 14),
            _buildTextField(
              _descriptionController,
              'Descripción',
              requerido: true,
              maxLines: 3,
            ),
            const SizedBox(height: 14),
            _buildTypeDropdown(),
            const SizedBox(height: 14),
            _buildTextField(
              _genresController,
              'Géneros (separados por coma, ej: Acción, Drama)',
            ),
            const SizedBox(height: 14),
            _buildTextField(_thumbnailUrlController, 'URL de miniatura (opcional)'),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _durationController,
                    'Duración (min)',
                    tipoNumerico: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    _releaseYearController,
                    'Año de estreno',
                    tipoNumerico: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _isPremium,
              onChanged: (value) => setState(() => _isPremium = value),
              activeColor: neonGreen,
              title: const Text('Contenido premium', style: TextStyle(color: Colors.white)),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            _buildVideoPicker(),
            const SizedBox(height: 24),
            if (_mensaje != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _mensaje!,
                  style: TextStyle(
                    color: _mensajeEsError ? Colors.redAccent : neonGreen,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _subiendo ? null : _enviar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: neonGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _subiendo
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'Subir contenido',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool requerido = false,
    bool tipoNumerico = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: tipoNumerico ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF141414),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: requerido
          ? (value) =>
              (value == null || value.trim().isEmpty) ? 'Campo obligatorio' : null
          : null,
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _type,
      dropdownColor: const Color(0xFF141414),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Tipo de contenido',
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF141414),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'movie', child: Text('Película')),
        DropdownMenuItem(value: 'series', child: Text('Serie')),
        DropdownMenuItem(value: 'documentary', child: Text('Documental')),
      ],
      onChanged: (value) {
        if (value != null) setState(() => _type = value);
      },
    );
  }

  Widget _buildVideoPicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(Icons.video_file_outlined, color: neonGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _videoFileName ?? 'Ningún video seleccionado',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: _subiendo ? null : _elegirVideo,
            child: const Text('Elegir video'),
          ),
        ],
      ),
    );
  }
}