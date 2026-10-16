import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/content_services.dart';
import '../widgets/admin/admin_app_bar.dart';
import '../widgets/admin/youtube_link_field.dart';
import '../widgets/admin/youtube_video_form.dart';

class AdminAddYoutubeScreen extends StatefulWidget {
  const AdminAddYoutubeScreen({super.key, required this.authService});

  final AuthService authService;

  static const Color neonGreen = Color(0xFF39FF14);

  @override
  State<AdminAddYoutubeScreen> createState() => _AdminAddYoutubeScreenState();
}

class _AdminAddYoutubeScreenState extends State<AdminAddYoutubeScreen> {
  late final _contentService = ContentService(authService: widget.authService);
  final _urlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _releaseYearController = TextEditingController();
  String _type = 'movie';
  String? _category;
  bool _isPremium = false;
  bool _cargandoPreview = false;
  bool _guardando = false;
  String? _error;
  YoutubePreviewResult? _preview;

  @override
  void dispose() {
    _urlController.dispose();
    _descriptionController.dispose();
    _releaseYearController.dispose();
    super.dispose();
  }

  Future<void> _buscarPreview() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    setState(() {
      _cargandoPreview = true;
      _error = null;
      _preview = null;
    });
    final result = await _contentService.obtenerPreviewYoutube(url);
    if (!mounted) return;
    setState(() {
      _cargandoPreview = false;
      _preview = result.success ? result : null;
      _error = result.success ? null : result.errorMessage;
    });
  }

  Future<void> _guardar() async {
    if (_category == null) {
      setState(() => _error = 'Selecciona una categoría');
      return;
    }
    setState(() => _guardando = true);
    final result = await _contentService.crearDesdeYoutube(
      videoUrl: _urlController.text.trim(),
      title: _preview!.title ?? 'Sin título',
      description: _descriptionController.text.trim(),
      type: _type,
      genres: _category!,
      releaseYear: int.tryParse(_releaseYearController.text.trim()),
      isPremium: _isPremium,
    );
    if (!mounted) return;
    setState(() => _guardando = false);
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video agregado correctamente')),
      );
      Navigator.pop(context, true); // true para refrescar el dashboard
    } else {
      setState(() => _error = result.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: const AdminAppBar(title: 'Agregar video por link'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          YoutubeLinkField(
            controller: _urlController,
            loading: _cargandoPreview,
            error: _error,
            onSearch: _buscarPreview,
          ),
          if (_preview != null)
            YoutubeVideoForm(
              preview: _preview!,
              descriptionController: _descriptionController,
              yearController: _releaseYearController,
              type: _type,
              category: _category,
              isPremium: _isPremium,
              saving: _guardando,
              onTypeChanged: (v) => setState(() => _type = v),
              onCategoryChanged: (c) => setState(() {
                _category = c;
                _error = null;
              }),
              onPremiumChanged: (v) => setState(() => _isPremium = v),
              onSubmit: _guardar,
            ),
        ],
      ),
    );
  }
}