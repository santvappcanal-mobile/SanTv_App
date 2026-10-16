import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:santv_app/models/live_comment.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Comentarios en vivo por Socket.IO (namespace /comments del backend).
/// Usa el mismo token de sesión que guarda AuthService ('auth_token').
class LiveCommentService {
  LiveCommentService({
    required this.baseUrl,
    this.roomId = 'canal-san-tv',
  });

  final String baseUrl;
  final String roomId;

  static const int _maxInMemory = 200;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  io.Socket? _socket;

  final List<LiveComment> _comments = [];
  final _commentsCtrl = StreamController<List<LiveComment>>.broadcast();
  final _errorsCtrl = StreamController<String>.broadcast();
  final _connCtrl = StreamController<bool>.broadcast();

  bool _connected = false;
  bool _disposed = false;

  Stream<List<LiveComment>> get commentsStream => _commentsCtrl.stream;
  Stream<String> get errorStream => _errorsCtrl.stream;
  Stream<bool> get connectionStream => _connCtrl.stream;
  List<LiveComment> get current => List.unmodifiable(_comments);
  bool get isConnected => _connected;

  Future<void> connect() async {
    if (_socket != null) return;

    final token = await _storage.read(key: 'auth_token');
    if (token == null || token.isEmpty || _disposed) return;

    final socket = io.io(
      '$baseUrl/comments',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .disableAutoConnect()
          .build(),
    );
    _socket = socket;

    socket.onConnect((_) {
      _setConnected(true);
      // Al (re)conectar se vuelve a entrar a la sala y llega el historial.
      socket.emit('comments_join', {'roomId': roomId});
    });
    socket.onDisconnect((_) => _setConnected(false));
    socket.onConnectError((_) => _setConnected(false));

    socket.on('comments_history', (data) {
      if (data is! List) return;
      _comments
        ..clear()
        ..addAll(data
            .whereType<Map>()
            .map((e) => LiveComment.fromJson(Map<String, dynamic>.from(e))));
      _emit();
    });

    socket.on('comment_new', (data) {
      if (data is! Map) return;
      final c = LiveComment.fromJson(Map<String, dynamic>.from(data));
      if (_comments.any((x) => x.id == c.id)) return;
      _comments.add(c);
      if (_comments.length > _maxInMemory) {
        _comments.removeRange(0, _comments.length - _maxInMemory);
      }
      _emit();
    });

    socket.on('comment_error', (data) {
      if (!_errorsCtrl.isClosed) _errorsCtrl.add(data.toString());
    });

    socket.connect();
  }

  void send(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return;
    _socket?.emit('comment_send', {'roomId': roomId, 'text': clean});
  }

  void _setConnected(bool value) {
    _connected = value;
    if (!_connCtrl.isClosed) _connCtrl.add(value);
  }

  void _emit() {
    if (!_commentsCtrl.isClosed) _commentsCtrl.add(List.unmodifiable(_comments));
  }

  void dispose() {
    _disposed = true;
    _socket?.dispose();
    _socket = null;
    _commentsCtrl.close();
    _errorsCtrl.close();
    _connCtrl.close();
  }
}
