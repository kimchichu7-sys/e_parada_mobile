import 'dart:async';

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
  @override
  void initState() {
    super.initState();
    unawaited(NotificationService.refreshUnreadCount());
  }

  Future<void> _openInbox() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
    if (mounted) {
      unawaited(NotificationService.refreshUnreadCount());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: NotificationService.unreadCountNotifier,
      builder: (context, unreadCount, _) {
        return IconButton(
          tooltip: unreadCount == 0
              ? 'Notifications'
              : 'Notifications, $unreadCount unread',
          onPressed: _openInbox,
          icon: Badge(
            isLabelVisible: unreadCount > 0,
            label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
            child: const Icon(Icons.notifications_none_rounded),
          ),
        );
      },
    );
  }
}
