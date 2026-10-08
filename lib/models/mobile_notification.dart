class MobileNotification {
  const MobileNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.link,
    required this.readAt,
    required this.createdAt,
    this.reservationId,
    this.dedupeKey,
    this.otherPartyName,
    this.canMessage,
  });

  final int id;
  final String title;
  final String message;
  final String type;
  final String link;
  final String? dedupeKey;
  final String? otherPartyName;
  final bool? canMessage;
  final DateTime? readAt;
  final DateTime? createdAt;
  final int? reservationId;

  bool get isUnread => readAt == null;

  bool get isMessageOrCall =>
      type == 'message' ||
      type == 'call' ||
      canMessage == true ||
      title.toLowerCase().contains('new message') ||
      title.toLowerCase().contains('incoming call') ||
      extractedReservationId != null;

  int? get extractedReservationId {
    if (reservationId != null && reservationId! > 0) return reservationId;
    final match = RegExp(r'reservations?/(\d+)', caseSensitive: false).firstMatch(link);
    if (match != null) return int.tryParse(match.group(1)!);
    if (dedupeKey != null && dedupeKey!.isNotEmpty) {
      final dMatch = RegExp(r':(\d+)(?::\d+)?$').firstMatch(dedupeKey!);
      if (dMatch != null) return int.tryParse(dMatch.group(1)!);
    }
    final msgMatch = RegExp(r'reservation\s*#?(\d+)', caseSensitive: false).firstMatch(message);
    if (msgMatch != null) return int.tryParse(msgMatch.group(1)!);
    final titleMatch = RegExp(r'reservation\s*#?(\d+)', caseSensitive: false).firstMatch(title);
    if (titleMatch != null) return int.tryParse(titleMatch.group(1)!);
    return null;
  }

  String get otherPartyDisplayName {
    if (otherPartyName != null && otherPartyName!.trim().isNotEmpty) {
      return otherPartyName!.trim();
    }
    final match = RegExp(r'^(?:New message from|Incoming Call from)\s*(.+)$', caseSensitive: false).firstMatch(title);
    if (match != null) return match.group(1)!.trim();
    return 'Driver / Space Provider';
  }

  factory MobileNotification.fromJson(Map<String, dynamic> json) {
    final linkStr = json['link']?.toString() ?? '';
    final dedupeStr = json['dedupe_key']?.toString() ?? '';
    int? resId = _nullableInteger(json['reservation_id']);
    if (resId == null && linkStr.isNotEmpty) {
      final m = RegExp(r'reservations?/(\d+)', caseSensitive: false).firstMatch(linkStr);
      if (m != null) resId = int.tryParse(m.group(1)!);
    }
    if (resId == null && dedupeStr.isNotEmpty) {
      final m = RegExp(r':(\d+)(?::\d+)?$').firstMatch(dedupeStr);
      if (m != null) resId = int.tryParse(m.group(1)!);
    }

    return MobileNotification(
      id: _integer(json['id']),
      title: json['title']?.toString() ?? 'E-Parada update',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      link: linkStr,
      dedupeKey: dedupeStr.isEmpty ? null : dedupeStr,
      otherPartyName: json['other_party_name']?.toString(),
      canMessage: json['can_message'] == true,
      reservationId: resId,
      readAt: DateTime.tryParse(json['read_at']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  static int _integer(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _nullableInteger(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
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
