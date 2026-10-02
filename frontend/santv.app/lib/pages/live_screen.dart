import 'package:flutter/material.dart';
import '../services/live_viewer_service.dart';
import '../widgets/live/live_cover_header.dart';
import '../widgets/live_viewers_bar.dart';

/// Pantalla de transmisión EN VIVO: muestra solo el en vivo ocupando
/// toda la pantalla, con el contador de espectadores en tiempo real.
class LiveScreen extends StatefulWidget {
  const LiveScreen({
    super.key,
    required this.liveId,
    required this.title,
    required this.description,
    required this.coverImageUrl,
    required this.currentUser,
    required this.baseUrl,
  });

  final String liveId;
  final String title;
  final String description;
  final String coverImageUrl;

  /// Usuario actual de la app: { id, name, avatarUrl }
  final Map<String, dynamic> currentUser;

  /// URL del backend (la misma de AuthService), ej: http://10.0.2.2:3000.
  /// Por ahí también corre el servidor Socket.IO del en vivo.
  final String baseUrl;

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  late final LiveViewerService _viewerService = LiveViewerService(
    baseUrl: widget.baseUrl,
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

            // Espectadores en tiempo real (avatares + "N viendo")
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: LiveViewersBar(service: _viewerService),
              ),
            ),
          ],
        ),
      ),
    );
  }
}