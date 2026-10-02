import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Escucha en tiempo real cuando el canal pasa a estar EN VIVO
/// (evento 'live_started' del backend).
class LiveStatusService {
  LiveStatusService({required this.baseUrl});

  final String baseUrl;
  io.Socket? _socket;

  void connect({
    required void Function(String title, String message) onLiveStarted,
    VoidCallback? onLiveEnded,
  }) {
    _socket?.dispose();

    final socket = io.io(
      baseUrl,
      io.OptionBuilder().setTransports(['websocket']).build(),
    );

    socket.on('live_started', (data) {
      final map = data is Map ? data : const {};
      onLiveStarted(
        (map['title'] ?? 'SAN TV está en vivo').toString(),
        (map['message'] ?? 'Entra ahora y mira la transmisión.').toString(),
      );
    });

    socket.on('live_ended', (_) => onLiveEnded?.call());

    socket.onConnectError(
      (e) => debugPrint('LiveStatusService: error de conexión: $e'),
    );

    _socket = socket;
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
  }
}
