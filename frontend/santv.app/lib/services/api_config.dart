// lib/services/api_config.dart
//
// Configuración central del backend de SAN TV.
// Todo lo relacionado con URLs, rutas y tiempos de espera vive aquí.

class ApiConfig {
  ApiConfig._();

  // ---------------------------------------------------------------------------
  // URLs del servidor
  // ---------------------------------------------------------------------------

  /// Backend en producción (Render). Sin "/api" y sin "/" al final.
  static const String produccion = 'https://santv-app.onrender.com';

  /// Direcciones para desarrollo local (solo para pruebas).
  static const String localhost = 'http://localhost:3000'; // PC o adb reverse
  static const String emulador = 'http://10.0.2.2:3000'; // Emulador Android
  static const String redLocal = 'http://192.168.1.135:3000'; // Teléfono por WiFi

  /// URL base que usa toda la app.
  ///
  /// Por defecto usa Render. Para probar contra tu servidor local sin tocar
  /// el código, ejecuta por ejemplo:
  ///   flutter run --dart-define=API_URL=http://10.0.2.2:3000
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: produccion,
  );

  /// URL de la API REST.
  static const String apiUrl = '$baseUrl/api';

  /// URL para Socket.IO (EN VIVO). Es el mismo servidor.
  static const String socketUrl = baseUrl;

  /// Namespace de Socket.IO para los comentarios en vivo.
  static const String commentsSocketUrl = '$baseUrl/comments';

  // ---------------------------------------------------------------------------
  // Rutas de la API (coinciden con las montadas en backend/src/index.js)
  // ---------------------------------------------------------------------------

  static const String users = '/api/users';
  static const String content = '/api/content';
  static const String liveEvents = '/api/live-events';
  static const String liveChannel = '/api/live-channel';
  static const String ads = '/api/ads';
  static const String notifications = '/api/notifications';
  static const String watchlist = '/api/watchlist';
  static const String uploads = '/api/uploads';
  static const String admin = '/api/admin';
  static const String chat = '/api/chat';
  static const String youtube = '/api/youtube';
  static const String adDocuments = '/api/ad-documents';
  static const String adReferences = '/api/ad-references';
  static const String adOrders = '/api/ad-orders';
  static const String devices = '/api/devices';

  /// Ruta de salud del backend (sirve para despertar Render).
  static const String health = '/health';

  // ---------------------------------------------------------------------------
  // Tiempos de espera
  // ---------------------------------------------------------------------------

  /// Tiempo normal para una petición.
  static const Duration requestTimeout = Duration(seconds: 15);

  /// Tiempo máximo para que Render "despierte" (plan gratuito).
  static const Duration wakeUpTimeout = Duration(seconds: 30);

  /// Tiempo para subidas de archivos pesados (videos, PDFs).
  static const Duration uploadTimeout = Duration(minutes: 5);

  // ---------------------------------------------------------------------------
  // Utilidades
  // ---------------------------------------------------------------------------

  /// Construye una URL completa a partir de una ruta.
  /// Ejemplo: ApiConfig.url(ApiConfig.content) -> https://.../api/content
  static String url(String path) {
    final limpia = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$limpia';
  }

  /// Uri lista para usar con el paquete http.
  static Uri uri(String path) => Uri.parse(url(path));
}