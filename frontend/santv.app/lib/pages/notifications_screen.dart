import 'package:flutter/material.dart';
import '../models/app_notification.dart';
import '../services/notification_service.dart';
import '../services/push_action_handler.dart';
import '../widgets/notifications/notifications_header.dart';
import '../widgets/notifications/notification_card.dart';
import '../widgets/notifications/mark_all_read_button.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, required this.notificationService});

  final NotificationService notificationService;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color _neon = Color(0xFF39FF14);

  // Misma lógica que usa el push para decidir a qué pantalla ir.
  late final PushActionHandler _actions = PushActionHandler(
    authService: widget.notificationService.authService,
  );

  List<AppNotification> _notifications = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await widget.notificationService.getNotifications();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.success) {
        _notifications = result.notifications;
        _error = null;
      } else {
        _error = result.errorMessage;
      }
    });
  }

  Future<void> _markAllAsRead() async {
    final ok = await widget.notificationService.markAllAsRead();
    if (!mounted || !ok) return;
    setState(() {
      _notifications =
          _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
  }

  /// Al tocar: la marca como leída y abre lo que anuncia
  /// (pedido de pauta, video nuevo o el en vivo).
  Future<void> _handleTap(AppNotification n) async {
    if (!n.isRead) {
      final ok = await widget.notificationService.markAsRead(n.id);
      if (ok && mounted) {
        setState(() {
          _notifications = _notifications
              .map((e) => e.id == n.id ? e.copyWith(isRead: true) : e)
              .toList();
        });
      }
    }
    if (!mounted) return;

    // En vivo: se cierra la bandeja y Home cambia a la pestaña del live.
    if (n.type == AppNotificationType.liveEvent) {
      Navigator.pop(context, 'live');
      return;
    }

    // Sin destino (sistema, promo): solo queda marcada como leída.
    if (n.type == AppNotificationType.system ||
        n.type == AppNotificationType.promo) {
      return;
    }

    final route = await _actions.routeFor(n.routeData);
    if (!mounted) return;
    if (route == null) {
      _aviso('No se pudo abrir esta notificación');
      return;
    }
    await Navigator.push(context, route);
  }

  void _aviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  /// Borra una notificación (deslizando). Devuelve true si el servidor la borró.
  Future<bool> _deleteOne(AppNotification n) async {
    final ok = await widget.notificationService.deleteNotification(n.id);
    if (!mounted) return false;
    if (!ok) _aviso('No se pudo borrar la notificación');
    return ok;
  }

  /// Borra todas las notificaciones ya leídas, con confirmación.
  Future<void> _deleteRead() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Borrar notificaciones leídas',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Se borrarán $_readCount notificaciones que ya leíste. '
          'Esta acción no se puede deshacer.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Borrar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    final ok = await widget.notificationService.deleteReadNotifications();
    if (!mounted) return;
    if (!ok) {
      _aviso('No se pudieron borrar las notificaciones');
      return;
    }
    setState(() {
      _notifications = _notifications.where((n) => !n.isRead).toList();
    });
    _aviso('Notificaciones leídas borradas');
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;
  int get _readCount => _notifications.length - _unreadCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B0B0B), Color(0xFF10241A), Color(0xFF0B0B0B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              NotificationsHeader(
                unreadCount: _unreadCount,
                onBack: () => Navigator.pop(context),
              ),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: _neon),
      );
    }
    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.white70)),
      );
    }
    if (_notifications.isEmpty) {
      return const Center(
        child: Text(
          'No tienes notificaciones',
          style: TextStyle(color: Colors.white38),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        ..._notifications.map(
          (n) => Dismissible(
            key: ValueKey(n.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) => _deleteOne(n),
            onDismissed: (_) {
              setState(() => _notifications.removeWhere((e) => e.id == n.id));
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            child: NotificationCard(
              notification: n,
              onTap: () => _handleTap(n),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_unreadCount > 0) MarkAllReadButton(onPressed: _markAllAsRead),
        if (_readCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              onPressed: _deleteRead,
              icon: const Icon(Icons.delete_sweep_outlined,
                  color: Colors.redAccent),
              label: Text(
                'Borrar leídas ($_readCount)',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
      ],
    );
  }
}