import 'package:flutter/material.dart';

import '../screens/notifications_screen.dart';
import '../services/notification_service.dart';

class NotificationActionButton extends StatefulWidget {
  const NotificationActionButton({super.key});

  @override
  State<NotificationActionButton> createState() =>
      _NotificationActionButtonState();
}

class _NotificationActionButtonState extends State<NotificationActionButton> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final inbox = await NotificationService.fetchInbox();
      if (mounted) setState(() => _unreadCount = inbox.unreadCount);
    } catch (_) {
      // The inbox itself presents connection errors when the user opens it.
    }
  }

  Future<void> _openInbox() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
    if (mounted) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: _unreadCount == 0
          ? 'Notifications'
          : 'Notifications, $_unreadCount unread',
      onPressed: _openInbox,
      icon: Badge(
        isLabelVisible: _unreadCount > 0,
        label: Text(_unreadCount > 99 ? '99+' : '$_unreadCount'),
        child: const Icon(Icons.notifications_none_rounded),
      ),
    );
  }
}
