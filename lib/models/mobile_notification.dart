class MobileNotification {
  const MobileNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.link,
    required this.readAt,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String message;
  final String type;
  final String link;
  final DateTime? readAt;
  final DateTime? createdAt;

  bool get isUnread => readAt == null;

  factory MobileNotification.fromJson(Map<String, dynamic> json) {
    return MobileNotification(
      id: _integer(json['id']),
      title: json['title']?.toString() ?? 'E-Parada update',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      link: json['link']?.toString() ?? '',
      readAt: DateTime.tryParse(json['read_at']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  static int _integer(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class NotificationTypeOption {
  const NotificationTypeOption({required this.key, required this.label});

  final String key;
  final String label;

  factory NotificationTypeOption.fromJson(Map<String, dynamic> json) {
    return NotificationTypeOption(
      key: json['key']?.toString() ?? 'all',
      label: json['label']?.toString() ?? 'All',
    );
  }
}

class NotificationInboxResult {
  const NotificationInboxResult({
    required this.notifications,
    required this.types,
    required this.unreadCount,
    required this.currentPage,
    required this.hasMore,
  });

  final List<MobileNotification> notifications;
  final List<NotificationTypeOption> types;
  final int unreadCount;
  final int currentPage;
  final bool hasMore;

  factory NotificationInboxResult.fromJson(Map<String, dynamic> json) {
    final notifications = json['notifications'];
    final types = json['types'];
    final pagination = _map(json['pagination']);

    return NotificationInboxResult(
      notifications: notifications is List
          ? notifications
                .whereType<Map>()
                .map(
                  (value) => MobileNotification.fromJson(
                    Map<String, dynamic>.from(value),
                  ),
                )
                .toList(growable: false)
          : const <MobileNotification>[],
      types: types is List
          ? types
                .whereType<Map>()
                .map(
                  (value) => NotificationTypeOption.fromJson(
                    Map<String, dynamic>.from(value),
                  ),
                )
                .toList(growable: false)
          : const [NotificationTypeOption(key: 'all', label: 'All')],
      unreadCount: _integer(json['unread_count']),
      currentPage: _integer(pagination['current_page']),
      hasMore: pagination['has_more'] == true,
    );
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static int _integer(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
