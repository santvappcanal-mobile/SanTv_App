import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/content_services.dart';

class AdminAddYoutubeScreen extends StatefulWidget {
  const AdminAddYoutubeScreen({super.key, required this.authService});

  final AuthService authService;

  static const Color neonGreen = Color(0xFF39FF14);

  @override
  State<AdminAddYoutubeScreen> createState() => _AdminAddYoutubeScreenState();
}

class _AdminAddYoutubeScreenState extends State<AdminAddYoutubeScreen> {
  late final ContentService _contentService;

  final _urlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _genresController = TextEditingController();
  final _releaseYearController = TextEditingController();

  String _type = 'movie';
  bool _isPremium = false;

  bool _cargandoPreview = false;
  bool _guardando = false;
  String? _error;

  YoutubePreviewResult? _preview;

  static const Color neonGreen = AdminAddYoutubeScreen.neonGreen;
  static const Color cardBg = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _contentService = ContentService(authService: widget.authService);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _descriptionController.dispose();
    _genresController.dispose();
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
      if (result.success) {
        _preview = result;
      } else {
        _error = result.errorMessage;
      }
    });
  }

  Future<void> _guardar() async {
    if (_preview == null) return;

    setState(() {
      _guardando = true;
      _error = null;
    });

    final result = await _contentService.crearDesdeYoutube(
      videoUrl: _urlController.text.trim(),
      title: _preview!.title ?? 'Sin título',
      description: _descriptionController.text.trim(),
      type: _type,
      genres: _genresController.text.trim(),
      releaseYear: int.tryParse(_releaseYearController.text.trim()),
      isPremium: _isPremium,
    );

    if (!mounted) return;

    setState(() => _guardando = false);

    if (result.success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video agregado correctamente')),
      );
      Navigator.pop(context, true); // devuelve true para refrescar el dashboard
    } else {
      setState(() => _error = result.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Agregar video por link',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _urlController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Link de YouTube',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: cardBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search, color: neonGreen),
                onPressed: _cargandoPreview ? null : _buscarPreview,
              ),
            ),
            onSubmitted: (_) => _buscarPreview(),
          ),
          const SizedBox(height: 16),
          if (_cargandoPreview)
            const Center(child: CircularProgressIndicator(color: neonGreen)),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          if (_preview != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _preview!.thumbnailUrl ?? '',
                      width: 90,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 90,
                        height: 60,
                        color: Colors.white12,
                        child: const Icon(Icons.movie, color: Colors.white38),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _preview!.title ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _preview!.channelName ?? '',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _type,
              dropdownColor: cardBg,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Tipo',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'movie', child: Text('Película')),
                DropdownMenuItem(value: 'series', child: Text('Serie')),
                DropdownMenuItem(
                  value: 'documentary',
                  child: Text('Documental'),
                ),
              ],
              onChanged: (value) => setState(() => _type = value ?? 'movie'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Descripción',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _genresController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Géneros (separados por coma)',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _releaseYearController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Año de estreno',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _isPremium,
              onChanged: (value) => setState(() => _isPremium = value),
              activeColor: neonGreen,
              title: const Text(
                'Contenido premium',
                style: TextStyle(color: Colors.white),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: neonGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _guardando
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        'Agregar video',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
