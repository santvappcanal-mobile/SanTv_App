import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart';

/// Se ejecuta cuando llega un mensaje con la app cerrada o en segundo plano.
/// Los mensajes con título/cuerpo (los que envía el backend) los muestra el
/// sistema solo; esto es únicamente por si algún día se envían datos puros.
/// Debe ser una función de nivel superior.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

/// Notificación recibida con la app abierta (primer plano).
class PushPayload {
  const PushPayload({
    required this.title,
    required this.body,
    required this.data,
  });

  final String title;
  final String body;
  final Map<String, dynamic> data;
}

/// Maneja Firebase Cloud Messaging: permisos, registro del token en el
/// backend y avisos de mensajes recibidos / tocados.
///
/// Si Firebase no está configurado (falta google-services.json) o la
/// plataforma no es Android/iOS, no hace nada y la app sigue funcionando.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  Future<void>? _initFuture;
  bool _available = false;

  String? _registeredToken;
  StreamSubscription<String>? _tokenRefreshSub;
  AuthService? _auth;

  Map<String, dynamic>? _pendingTap;

  final _foregroundController = StreamController<PushPayload>.broadcast();
  final _tapController = StreamController<Map<String, dynamic>>.broadcast();

  /// Mensajes que llegan con la app abierta.
  Stream<PushPayload> get onForeground => _foregroundController.stream;

  /// El usuario tocó una notificación (con la app abierta o en segundo plano).
  Stream<Map<String, dynamic>> get onTap => _tapController.stream;

  bool get _supportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Notificación que abrió la app estando cerrada (solo se entrega una vez).
  Map<String, dynamic>? takePendingTap() {
    final tap = _pendingTap;
    _pendingTap = null;
    return tap;
  }

  /// Inicializa Firebase y los listeners. Se puede llamar varias veces.
  Future<void> init() => _initFuture ??= _init();

  Future<void> _init() async {
    if (!_supportedPlatform) return;

    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      _available = true;

      final messaging = FirebaseMessaging.instance;

      // Android 13+ e iOS piden permiso al usuario.
      await messaging.requestPermission();

      // Con la app abierta, Android no muestra la notificación del sistema:
      // se la pasamos a Home para que muestre un aviso dentro de la app.
      FirebaseMessaging.onMessage.listen((message) {
        final notification = message.notification;
        _foregroundController.add(
          PushPayload(
            title: notification?.title ?? message.data['title']?.toString() ?? '',
            body: notification?.body ?? message.data['body']?.toString() ?? '',
            data: Map<String, dynamic>.from(message.data),
          ),
        );
      });

      // Toque sobre la notificación con la app en segundo plano.
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _tapController.add(Map<String, dynamic>.from(message.data));
      });

      // Toque sobre la notificación con la app cerrada.
      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        _pendingTap = Map<String, dynamic>.from(initial.data);
      }
    } catch (e) {
      _available = false;
      debugPrint('Push: Firebase no disponible ($e)');
    }
  }

  /// Guarda el token de este dispositivo en el backend para el usuario
  /// que tiene la sesión iniciada. Llamar después del login.
  Future<void> registerDevice(AuthService auth) async {
    await init();
    if (!_available) return;
    _auth = auth;

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _sendToken(auth, token);

      await _tokenRefreshSub?.cancel();
      _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((t) {
        final current = _auth;
        if (current != null) _sendToken(current, t);
      });
    } catch (e) {
      debugPrint('Push: no se pudo registrar el dispositivo ($e)');
    }
  }

  /// Quita el token del backend para que este teléfono deje de recibir las
  /// notificaciones de ese usuario. Llamar ANTES de authService.logout().
  Future<void> unregisterDevice(AuthService auth) async {
    if (!_available) return;

    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
    _auth = null;

    final token = _registeredToken;
    _registeredToken = null;

    try {
      if (token != null) {
        final jwt = await auth.getToken();
        if (jwt != null) {
          await http
              .post(
                Uri.parse('${auth.baseUrl}/api/devices/unregister'),
                headers: _headers(jwt),
                body: jsonEncode({'token': token}),
              )
              .timeout(const Duration(seconds: 8));
        }
      }
      // El próximo inicio de sesión recibirá un token nuevo.
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint('Push: no se pudo quitar el dispositivo ($e)');
    }
  }

  Map<String, String> _headers(String jwt) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $jwt',
  };

  Future<void> _sendToken(AuthService auth, String token) async {
    try {
      final jwt = await auth.getToken();
      if (jwt == null) return;

      final response = await http
          .post(
            Uri.parse('${auth.baseUrl}/api/devices/register'),
            headers: _headers(jwt),
            body: jsonEncode({
              'token': token,
              'platform': defaultTargetPlatform == TargetPlatform.iOS
                  ? 'ios'
                  : 'android',
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _registeredToken = token;
      } else {
        debugPrint('Push: el backend rechazó el token (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Push: error enviando el token ($e)');
    }
  }
}
