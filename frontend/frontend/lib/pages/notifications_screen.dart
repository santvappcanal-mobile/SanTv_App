import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/app_notification.dart';
import '../services/notification_service.dart';

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

  ({IconData icon, Color color}) _styleFor(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.liveEvent:
        return (icon: Icons.podcasts, color: const Color(0xFFFF4444));
      case AppNotificationType.newContent:
        return (icon: Icons.video_library, color: const Color(0xFF39FF14));
      case AppNotificationType.promo:
        return (icon: Icons.trending_up, color: const Color(0xFFFFA726));
      case AppNotificationType.billing:
        return (icon: Icons.credit_card, color: const Color(0xFF64B5F6));
      case AppNotificationType.system:
        return (icon: Icons.notifications_none, color: const Color(0xFF64B5F6));
    }
  }

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
              _buildHeader(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.03),
                ],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notificaciones',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_unreadCount > 0)
                        Text(
                          '$_unreadCount nuevas',
                          style: const TextStyle(
                            color: Color(0xFF39FF14),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
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
        ..._notifications.map(_buildCard),
        const SizedBox(height: 12),
        if (_unreadCount > 0)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _markAllAsRead,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Marcar todas como leídas'),
            ),
          ),
      ],
    );
  }

  Widget _buildCard(AppNotification n) {
    final style = _styleFor(n.type);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: InkWell(
            onTap: () => _handleTap(n),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.03),
                  ],
                ),
                border: Border.all(
                  color: !n.isRead
                      ? const Color(0xFF39FF14).withOpacity(0.4)
                      : Colors.white.withOpacity(0.12),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: style.color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(style.icon, color: style.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                n.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (!n.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF39FF14),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          n.message,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          n.relativeTime,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}