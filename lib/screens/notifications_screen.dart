import 'package:flutter/material.dart';

import '../models/mobile_notification.dart';
import '../services/notification_service.dart';
import 'reservation_conversation_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<MobileNotification> _notifications = const [];
  List<NotificationTypeOption> _types = const [
    NotificationTypeOption(key: 'all', label: 'All'),
  ];
  String _selectedType = 'all';
  String? _error;
  int _page = 1;
  int _unreadCount = 0;
  bool _hasMore = false;
  bool _loading = true;
  bool _loadingMore = false;
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({required bool reset}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      if (_loadingMore || !_hasMore) return;
      setState(() => _loadingMore = true);
    }

    try {
      final result = await NotificationService.fetchInbox(
        type: _selectedType,
        page: reset ? 1 : _page + 1,
      );
      if (!mounted) return;
      setState(() {
        _notifications = reset
            ? result.notifications
            : [..._notifications, ...result.notifications];
        _types = result.types;
        _page = result.currentPage;
        _unreadCount = result.unreadCount;
        _hasMore = result.hasMore;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  Future<void> _selectType(String type) async {
    if (_selectedType == type) return;
    setState(() => _selectedType = type);
    await _load(reset: true);
  }

  Future<void> _perform(Future<String> Function() action) async {
    if (_acting) return;
    setState(() => _acting = true);
    try {
      final message = await action();
      if (!mounted) return;
      await _load(reset: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  void _navigateToConversation(int reservationId, String otherPartyName) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReservationConversationScreen(
          reservationId: reservationId,
          otherPartyName: otherPartyName,
        ),
      ),
    );
  }

  Future<void> _open(MobileNotification notification) async {
    if (notification.isUnread) {
      await _perform(() => NotificationService.markAsRead(notification.id));
      if (!mounted) return;
    }

    final reservationId = notification.extractedReservationId;
    final otherPartyName = notification.otherPartyDisplayName;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(_icon(notification.type)),
        title: Text(notification.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            if (reservationId != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(dialogContext).colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      notification.type == 'call'
                          ? Icons.phone_in_talk_rounded
                          : Icons.chat_bubble_outline_rounded,
                      size: 18,
                      color: Theme.of(dialogContext).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        notification.type == 'call'
                            ? 'Call / Chat connected to Reservation #$reservationId'
                            : 'Direct chat available for Reservation #$reservationId',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(dialogContext).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          if (reservationId != null)
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                _navigateToConversation(reservationId, otherPartyName);
              },
              icon: Icon(
                notification.type == 'call'
                    ? Icons.phone_rounded
                    : Icons.chat_bubble_rounded,
                size: 18,
              ),
              label: Text(
                notification.type == 'call' ? 'Call / Open Chat' : 'Message Directly',
              ),
            )
          else
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Done'),
            ),
        ],
      ),
    );
  }

  Future<void> _clear(bool all) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          all ? 'Clear all notifications?' : 'Clear read notifications?',
        ),
        content: Text(
          all
              ? 'This permanently removes every notification in your inbox.'
              : 'This permanently removes notifications you have already read.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _perform(
      all ? NotificationService.clearAll : NotificationService.clearRead,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _unreadCount == 0 ? 'Notifications' : 'Notifications ($_unreadCount)',
        ),
        actions: [
          IconButton(
            tooltip: 'Mark all as read',
            onPressed: _acting || _unreadCount == 0
                ? null
                : () => _perform(NotificationService.markAllAsRead),
            icon: const Icon(Icons.done_all_rounded),
          ),
          PopupMenuButton<String>(
            enabled: !_acting,
            onSelected: (value) => _clear(value == 'all'),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'read', child: Text('Clear read')),
              PopupMenuItem(value: 'all', child: Text('Clear all')),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _FilterBar(
                types: _types,
                selected: _selectedType,
                onSelected: _selectType,
              ),
              Expanded(child: _body()),
            ],
          ),
          if (_acting)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x22000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _notifications.isEmpty) {
      return _MessageState(
        icon: Icons.cloud_off_outlined,
        message: _error!,
        onRetry: () => _load(reset: true),
      );
    }
    if (_notifications.isEmpty) {
      return _MessageState(
        icon: Icons.notifications_none_rounded,
        message: _selectedType == 'all'
            ? 'Your notification inbox is empty.'
            : 'No notifications match this filter.',
        onRetry: () => _load(reset: true),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _notifications.length + (_hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == _notifications.length) {
            return Center(
              child: OutlinedButton.icon(
                onPressed: _loadingMore ? null : () => _load(reset: false),
                icon: _loadingMore
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.expand_more_rounded),
                label: const Text('Load older'),
              ),
            );
          }

          final notification = _notifications[index];
          final resId = notification.extractedReservationId;
          return _NotificationCard(
            notification: notification,
            disabled: _acting,
            onOpen: () => _open(notification),
            onDelete: () => _perform(
              () => NotificationService.deleteNotification(notification.id),
            ),
            onReply: resId != null
                ? () {
                    if (notification.isUnread) {
                      NotificationService.markAsRead(notification.id).catchError((_) => '');
                    }
                    _navigateToConversation(resId, notification.otherPartyDisplayName);
                  }
                : null,
          );
        },
      ),
    );
  }

  static IconData _icon(String type) {
    return switch (type) {
      'message' => Icons.chat_bubble_outline_rounded,
      'call' => Icons.phone_in_talk_outlined,
      'reservation' => Icons.event_note_outlined,
      'payment' => Icons.payments_outlined,
      'verification' => Icons.verified_user_outlined,
      'parking_space' => Icons.local_parking_outlined,
      'feedback' => Icons.reviews_outlined,
      _ => Icons.notifications_outlined,
    };
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.types,
    required this.selected,
    required this.onSelected,
  });

  final List<NotificationTypeOption> types;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: types.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = types[index];
          return FilterChip(
            label: Text(type.label),
            selected: selected == type.key,
            onSelected: (_) => onSelected(type.key),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.disabled,
    required this.onOpen,
    required this.onDelete,
    this.onReply,
  });

  final MobileNotification notification;
  final bool disabled;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final VoidCallback? onReply;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: notification.isUnread ? colors.primaryContainer : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: disabled ? null : onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _NotificationsScreenState._icon(notification.type),
                color: notification.isUnread ? colors.primary : null,
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
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isUnread
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (notification.isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notification.message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _timestamp(notification.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (notification.extractedReservationId != null) ...[
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        ),
                        onPressed: disabled ? null : onReply,
                        icon: Icon(
                          notification.type == 'call'
                              ? Icons.phone_rounded
                              : Icons.chat_bubble_outline_rounded,
                          size: 15,
                        ),
                        label: Text(
                          notification.type == 'call' ? 'Call / Chat' : 'Message Directly',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Delete notification',
                onPressed: disabled ? null : onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _timestamp(DateTime? value) {
    if (value == null) return '';
    final local = value.toLocal();
    final now = DateTime.now();
    final difference = now.difference(local);

    if (!difference.isNegative && difference.inMinutes < 1) return 'Just now';
    if (!difference.isNegative && difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    }
    if (!difference.isNegative && difference.inDays < 1) {
      return '${difference.inHours} hr ago';
    }

    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    required this.onRetry,
  });

  final IconData icon;
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
