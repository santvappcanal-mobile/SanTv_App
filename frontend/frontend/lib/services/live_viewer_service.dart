import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/live_viewer.dart';

/// Servicio encargado de la conexión en tiempo real a un EN VIVO:
/// mantiene el conteo de espectadores y la lista de quiénes están
/// conectados en ese momento (estilo Facebook Live).
///
/// Se comunica por WebSocket (Socket.IO) con el backend. El backend
/// debe respetar este contrato de eventos:
///
///   Cliente -> Servidor
///     'join_live'   { liveId, user: { id, name, avatarUrl } }
///     'leave_live'  { liveId }
///
///   Servidor -> Cliente
///     'viewer_count'    int
///     'viewers_update'  List<{ id, name, avatarUrl, joinedAt }>
///
/// Cada vez que un usuario se une o se desconecta, el backend debe
/// recalcular y volver a emitir 'viewer_count' y 'viewers_update' a
/// todos los conectados a ese liveId (broadcast por sala/room).
class LiveViewerService {
  LiveViewerService({required this.baseUrl});

  /// URL base del servidor Socket.IO, ej: https://api.santv.com
  final String baseUrl;

  io.Socket? _socket;
  String? _currentLiveId;

  final _viewerCountController = StreamController<int>.broadcast();
  final _viewersListController =
      StreamController<List<LiveViewer>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  Stream<int> get viewerCountStream => _viewerCountController.stream;
  Stream<List<LiveViewer>> get viewersListStream =>
      _viewersListController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  int _lastCount = 0;
  List<LiveViewer> _lastViewers = [];

  int get currentCount => _lastCount;
  List<LiveViewer> get currentViewers => _lastViewers;
  bool get isConnected => _socket?.connected ?? false;

  /// Conecta al servidor y se une al conteo en tiempo real de [liveId].
  /// [user] es el usuario actual de la app: { id, name, avatarUrl }.
  void joinLive({
    required String liveId,
    required Map<String, dynamic> user,
  }) {
    _currentLiveId = liveId;

    _socket ??= io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .build(),
    );

    final socket = _socket!;

    // Evita listeners duplicados si joinLive se llama más de una vez
    // (por ejemplo, al cambiar de EN VIVO).
    socket
      ..off('connect')
      ..off('disconnect')
      ..off('viewer_count')
      ..off('viewers_update');

    socket.onConnect((_) {
      _connectionController.add(true);
      socket.emit('join_live', {'liveId': liveId, 'user': user});
    });

    socket.onDisconnect((_) {
      _connectionController.add(false);
    });

    socket.on('viewer_count', (data) {
      final count = data is int ? data : int.tryParse('$data') ?? 0;
      _lastCount = count;
      _viewerCountController.add(count);
    });

    socket.on('viewers_update', (data) {
      if (data is List) {
        final viewers = data
            .whereType<Map>()
            .map((e) => LiveViewer.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        _lastViewers = viewers;
        _viewersListController.add(viewers);
      }
    });

    if (socket.connected) {
      socket.emit('join_live', {'liveId': liveId, 'user': user});
    } else {
      socket.connect();
    }
  }

  /// Sale del EN VIVO actual (por ejemplo, al salir de la pantalla).
  void leaveLive() {
    if (_currentLiveId != null && _socket?.connected == true) {
      _socket!.emit('leave_live', {'liveId': _currentLiveId});
    }
    _currentLiveId = null;
  }

  void dispose() {
    leaveLive();
    _socket?.dispose();
    _socket = null;
    _viewerCountController.close();
    _viewersListController.close();
    _connectionController.close();
  }
}
