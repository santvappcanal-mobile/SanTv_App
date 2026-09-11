import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/content_services.dart';
import '../widgets/admin/custom_text_field.dart';
import '../widgets/admin/content_type_dropdown.dart';
import '../widgets/admin/video_picker_field.dart';
import '../widgets/admin/upload_status_message.dart';
import '../widgets/admin/upload_submit_button.dart';

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
  final _videoUrlController = TextEditingController(); // NUEVO

  String _type = 'movie';
  bool _isPremium = false;
  bool _usarUrlExterna = false; // NUEVO: alterna entre subir archivo o pegar link
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
    _videoUrlController.dispose(); // NUEVO
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

  bool _esUrlValida(String value) {
    final uri = Uri.tryParse(value.trim());
    return uri != null &&
        uri.hasScheme &&
        (uri.isScheme('http') || uri.isScheme('https'));
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_usarUrlExterna) {
      final url = _videoUrlController.text.trim();
      if (url.isEmpty || !_esUrlValida(url)) {
        setState(() {
          _mensaje = 'Ingresa una URL de video válida (http/https).';
          _mensajeEsError = true;
        });
        return;
      }
    } else if (_videoFile == null) {
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

    // TODO: 'crearConUrlExterna' aún no existe en ContentService.
    // Debe crear el Content directamente con el campo videoUrl,
    // sin pasar por /api/uploads/video (sin Cloudinary de por medio).
    final result = _usarUrlExterna
        ? await _contentService.crearConUrlExterna(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            type: _type,
            videoUrl: _videoUrlController.text.trim(),
            genres: _genresController.text.trim(),
            thumbnailUrl: _thumbnailUrlController.text.trim(),
            duration: int.tryParse(_durationController.text.trim()),
            releaseYear: int.tryParse(_releaseYearController.text.trim()),
            isPremium: _isPremium,
          )
        : await _contentService.subirVideo(
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
          ? 'Contenido guardado correctamente.'
          : (result.errorMessage ?? 'Ocurrió un error al guardar el contenido.');
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
      _videoUrlController.clear();
      setState(() {
        _videoFile = null;
        _videoFileName = null;
        _type = 'movie';
        _isPremium = false;
        _usarUrlExterna = false;
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
            CustomTextField(
              controller: _titleController,
              label: 'Título',
              requerido: true,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _descriptionController,
              label: 'Descripción',
              requerido: true,
              maxLines: 3,
            ),
            const SizedBox(height: 14),
            ContentTypeDropdown(
              value: _type,
              onChanged: (value) => setState(() => _type = value),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _genresController,
              label: 'Géneros (separados por coma, ej: Acción, Drama)',
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _thumbnailUrlController,
              label: 'URL de miniatura (opcional)',
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _durationController,
                    label: 'Duración (min)',
                    tipoNumerico: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _releaseYearController,
                    label: 'Año de estreno',
                    tipoNumerico: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _isPremium,
              onChanged: (value) => setState(() => _isPremium = value),
              activeThumbColor: neonGreen,
              title: const Text('Contenido premium', style: TextStyle(color: Colors.white)),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _usarUrlExterna,
              onChanged: (value) => setState(() {
                _usarUrlExterna = value;
                _mensaje = null;
              }),
              activeColor: neonGreen,
              title: const Text(
                'Usar URL de video externo',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Actívalo para videos grandes (evita el límite de 100 MB de Cloudinary)',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            if (_usarUrlExterna)
              CustomTextField(
                controller: _videoUrlController,
                label: 'URL del video (YouTube, streaming propio, etc.)',
                requerido: true,
              )
            else
              VideoPickerField(
                fileName: _videoFileName,
                onPick: _elegirVideo,
                enabled: !_subiendo,
                accentColor: neonGreen,
              ),
            const SizedBox(height: 24),
            if (_mensaje != null)
              UploadStatusMessage(
                message: _mensaje!,
                isError: _mensajeEsError,
                successColor: neonGreen,
              ),
            UploadSubmitButton(
              isLoading: _subiendo,
              onPressed: _enviar,
              backgroundColor: neonGreen,
            ),
          ],
        ),
      ),
    );
  }
}