import 'package:e_parada_mobile/models/mobile_notification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'notification inbox parses items, filters, unread count and pagination',
    () {
      final inbox = NotificationInboxResult.fromJson({
        'notifications': [
          {
            'id': 9,
            'title': 'Reservation approved',
            'message': 'Your reservation is ready.',
            'type': 'reservation',
            'link': '/driver/reservations',
            'read_at': null,
            'created_at': '2026-08-16T10:30:00+00:00',
          },
        ],
        'unread_count': 1,
        'types': [
          {'key': 'all', 'label': 'All'},
          {'key': 'reservation', 'label': 'Reservations'},
        ],
        'pagination': {'current_page': 1, 'last_page': 2, 'has_more': true},
      });

      expect(inbox.notifications, hasLength(1));
      expect(inbox.notifications.single.id, 9);
      expect(inbox.notifications.single.isUnread, isTrue);
      expect(inbox.notifications.single.type, 'reservation');
      expect(inbox.notifications.single.createdAt, isNotNull);
      expect(inbox.types.last.label, 'Reservations');
      expect(inbox.unreadCount, 1);
      expect(inbox.currentPage, 1);
      expect(inbox.hasMore, isTrue);
    },
  );

  test('read notification and incomplete values have safe defaults', () {
    final notification = MobileNotification.fromJson({
      'id': '12',
      'read_at': '2026-08-16T11:00:00Z',
    });

    expect(notification.id, 12);
    expect(notification.title, 'E-Parada update');
    expect(notification.message, isEmpty);
    expect(notification.type, 'general');
    expect(notification.isUnread, isFalse);
  });
}
