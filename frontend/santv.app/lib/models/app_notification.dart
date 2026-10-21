enum AppNotificationType { system, newContent, liveEvent, billing, promo }

AppNotificationType _typeFromString(String? raw) {
  switch (raw) {
    case 'new_content':
      return AppNotificationType.newContent;
    case 'live_event':
      return AppNotificationType.liveEvent;
    case 'billing':
      return AppNotificationType.billing;
    case 'promo':
      return AppNotificationType.promo;
    case 'system':
    default:
      return AppNotificationType.system;
  }
}

String _typeKey(AppNotificationType t) {
  switch (t) {
    case AppNotificationType.newContent:
      return 'new_content';
    case AppNotificationType.liveEvent:
      return 'live_event';
    case AppNotificationType.billing:
      return 'billing';
    case AppNotificationType.promo:
      return 'promo';
    case AppNotificationType.system:
      return 'system';
  }
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final AppNotificationType type;
  final bool isRead;
  final String actionUrl;
  final DateTime createdAt;

  /// Datos para abrir la pantalla al tocarla (contentId, orderId, forAdmin...).
  final Map<String, dynamic> data;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.actionUrl,
    required this.createdAt,
    this.data = const {},
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return AppNotification(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: _typeFromString(json['type']?.toString()),
      isRead: json['isRead'] == true,
      actionUrl: json['actionUrl']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      data: rawData is Map ? Map<String, dynamic>.from(rawData) : const {},
    );
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl,
      createdAt: createdAt,
      data: data,
    );
  }

  /// Mismo formato que el `data` de un push, para reutilizar
  /// PushActionHandler.routeFor(). También entiende las notificaciones
  /// antiguas que solo guardaron actionUrl (ej. "/content/123").
  Map<String, dynamic> get routeData {
    final map = <String, dynamic>{'type': _typeKey(type), ...data};

    if (type == AppNotificationType.newContent &&
        (map['contentId']?.toString().isEmpty ?? true) &&
        actionUrl.startsWith('/content/')) {
      map['contentId'] = actionUrl.substring('/content/'.length);
    }
    return map;
  }

  /// "Hace 5 min", "Hace 2 horas", etc.
  String get relativeTime {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} horas';
    return 'Hace ${diff.inDays} días';
  }
}