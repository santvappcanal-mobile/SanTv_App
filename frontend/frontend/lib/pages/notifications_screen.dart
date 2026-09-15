import 'package:flutter/material.dart';
import '../models/app_notification.dart';
import '../services/notification_service.dart';
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
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

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
        child: CircularProgressIndicator(color: Color(0xFF39FF14)),
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
          (n) => NotificationCard(
            notification: n,
            onTap: () => _handleTap(n),
          ),
        ),
        const SizedBox(height: 12),
        if (_unreadCount > 0) MarkAllReadButton(onPressed: _markAllAsRead),
      ],
    );
  }
}