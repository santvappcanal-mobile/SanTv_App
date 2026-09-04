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

class AppNotification {
  final String id;
  final String title;
  final String message;
  final AppNotificationType type;
  final bool isRead;
  final String actionUrl;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.actionUrl,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: _typeFromString(json['type']?.toString()),
      isRead: json['isRead'] == true,
      actionUrl: json['actionUrl']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
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
    );
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