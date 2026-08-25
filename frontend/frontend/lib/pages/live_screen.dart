import 'package:flutter/material.dart';
import '../services/live_viewer_service.dart';
import '../widgets/live_viewers_bar.dart';
// import '../widgets/top_bar.dart'; // Reutiliza tu TopBar existente aquí

/// Pantalla de transmisión EN VIVO (mismo diseño de la referencia),
/// pero con el conteo de espectadores totalmente en tiempo real:
/// ya NO se muestra el número fijo "15,234 espectadores".
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
  late final LiveViewerService _viewerService =
      LiveViewerService(baseUrl: 'https://TU_BACKEND_SOCKET_IO');

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
      backgroundColor: const Color(0xFF0B0B0B),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const TopBar(), // tu barra superior existente (logo, buscar, notificaciones, perfil)

              Stack(
                children: [
                  ClipRRect(
                    child: Image.network(
                      widget.coverImageUrl,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    height: 220,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.greenAccent.withOpacity(0.6)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.circle, color: Colors.red, size: 10),
                          SizedBox(width: 6),
                          Text(
                            'TRANSMISIÓN EN VIVO',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: IconButton(
                      icon: Icon(
                        _muted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        shape: const CircleBorder(),
                      ),
                      onPressed: () => setState(() => _muted = !_muted),
                    ),
                  ),
                ],
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
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            SizedBox(width: 4),
                            Text('9.1', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        Text(
                          '${DateTime.now().year}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        // Conteo y avatares en tiempo real (reemplaza al
                        // texto fijo "15,234 viendo" de la referencia).
                        LiveViewersBar(service: _viewerService),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white38),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('HD',
                              style:
                                  TextStyle(color: Colors.white70, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.description,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {},
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Unirse Ahora'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.add),
                          label: const Text('Mi Lista'),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.info_outline, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}