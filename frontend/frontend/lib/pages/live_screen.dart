import 'package:flutter/material.dart';
import '../services/live_viewer_service.dart';
import '../widgets/live/live_cover_header.dart';
import '../widgets/live/live_meta_row.dart';
import '../widgets/live/live_action_buttons.dart';

// import '../widgets/top_bar.dart'; // Reutiliza tu TopBar existente aquí

/// Pantalla de transmisión EN VIVO, ahora compuesta por widgets
/// separados (widgets/live/) en vez de tener todo el diseño inline.
class LiveScreen extends StatefulWidget {
  const LiveScreen({
    super.key,
    required this.liveId,
    required this.title,
    required this.description,
    required this.coverImageUrl,
    required this.currentUser,
  });

  final String liveId;
  final String title;
  final String description;
  final String coverImageUrl;

  /// Usuario actual de la app: { id, name, avatarUrl }
  final Map<String, dynamic> currentUser;

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  // TODO: reemplaza por la URL real de tu servidor Socket.IO
  late final LiveViewerService _viewerService = LiveViewerService(
    baseUrl: 'https://TU_BACKEND_SOCKET_IO',
  );

  bool _muted = true;

  @override
  void initState() {
    super.initState();
    _viewerService.joinLive(liveId: widget.liveId, user: widget.currentUser);
  }

  @override
  void dispose() {
    // Al salir de la pantalla, el usuario se desconecta y el conteo
    // baja en tiempo real para todos los demás espectadores.
    _viewerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B0B0B), Color(0xFF10241A), Color(0xFF0B0B0B)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const TopBar(), // tu barra superior existente

                LiveCoverHeader(
                  coverImageUrl: widget.coverImageUrl,
                  muted: _muted,
                  onToggleMute: () => setState(() => _muted = !_muted),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      LiveMetaRow(
                        rating: 9.1,
                        year: DateTime.now().year,
                        viewerService: _viewerService,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        widget.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      LiveActionButtons(
                        onJoin: () {},
                        onAddToList: () {},
                        onInfo: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}