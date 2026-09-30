import 'package:flutter/material.dart';
import '../services/live_viewer_service.dart';
import '../widgets/live/live_cover_header.dart';

/// Pantalla de transmisión EN VIVO: muestra solo el en vivo ocupando
/// toda la pantalla (sin ficha de título, rating, descripción ni botones).
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // El en vivo ocupa toda la pantalla
            Positioned.fill(
              child: LiveCoverHeader(
                coverImageUrl: widget.coverImageUrl,
                muted: _muted,
                onToggleMute: () => setState(() => _muted = !_muted),
                badgeLeft: 64,
              ),
            ),

            // Flecha para volver
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}