import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:e_parada_mobile/models/admin_models.dart';
import 'package:e_parada_mobile/models/reservation_call.dart';
import 'package:e_parada_mobile/screens/admin_reviews_screen.dart';
import 'package:e_parada_mobile/screens/notifications_screen.dart';
import 'package:e_parada_mobile/services/api_client.dart';
import 'package:e_parada_mobile/services/auth_service.dart';
import 'package:e_parada_mobile/services/conversation_service.dart';
import 'package:e_parada_mobile/services/notification_service.dart';
import 'package:e_parada_mobile/widgets/notification_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

http.Response _jsonResponse(Map<String, dynamic> body, {int statusCode = 200}) {
  return http.Response(
    jsonEncode(body),
    statusCode,
    headers: const {'content-type': 'application/json'},
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'test-token-123',
      'user_id': 7,
      'user_name': 'Driver One',
      'user_email': 'driver@example.com',
      'user_role': 'driver',
    });
    NotificationService.syncUnreadCount(0);
  });

  tearDown(() {
    ApiClient.resetClient();
    NotificationService.syncUnreadCount(0);
  });

  test(
    'ApiClient reuses persistent testing client across get, postJson, and postMultipart',
    () async {
      final seenMethods = <String>[];
      final seenPaths = <String>[];
      final mockClient = MockClient((request) async {
        seenMethods.add(request.method);
        seenPaths.add(request.url.path);
        return _jsonResponse({'ok': true, 'path': request.url.path});
      });

      ApiClient.setClientForTesting(mockClient);

      final r1 = await ApiClient.get('notifications?type=all&page=1');
      final r2 = await ApiClient.postJson('login', body: {'email': 'a@b.c'});
      final r3 = await ApiClient.postMultipart(
        'vehicles',
        fields: {'plate_number': 'ABC 1234'},
        files: {
          'photo': UploadFileData(
            bytes: Uint8List.fromList([1, 2, 3]),
            filename: 'plate.jpg',
          ),
        },
      );

      expect(r1.statusCode, 200);
      expect(r2.statusCode, 200);
      expect(r3.statusCode, 200);
      expect(seenMethods, ['GET', 'POST', 'POST']);
      expect(seenPaths, [
        '/api/notifications',
        '/api/login',
        '/api/vehicles',
      ]);
    },
  );

  test(
    'NotificationService keeps unreadCountNotifier synchronized and deduplicates concurrent refreshes',
    () async {
      var inboxFetches = 0;
      ApiClient.setClientForTesting(
        MockClient((request) async {
          if (request.url.path.endsWith('/notifications') &&
              request.method == 'GET') {
            inboxFetches += 1;
            await Future<void>.delayed(const Duration(milliseconds: 20));
            return _jsonResponse({
              'notifications': [],
              'unread_count': 4,
              'types': [
                {'key': 'all', 'label': 'All'},
              ],
              'pagination': {
                'current_page': 1,
                'last_page': 1,
                'has_more': false,
              },
            });
          }
          if (request.url.path.endsWith('/notifications/10/read')) {
            return _jsonResponse({
              'message': 'Notification marked as read.',
              'unread_count': 3,
            });
          }
          if (request.url.path.endsWith('/notifications/11') &&
              request.method == 'DELETE') {
            return _jsonResponse({
              'message': 'Notification deleted.',
              'unread_count': 2,
            });
          }
          if (request.url.path.endsWith('/notifications/read-all')) {
            return _jsonResponse({'message': 'Notifications marked as read.'});
          }
          return _jsonResponse({'message': 'Unhandled'}, statusCode: 404);
        }),
      );

      await Future.wait([
        NotificationService.refreshUnreadCount(),
        NotificationService.refreshUnreadCount(),
        NotificationService.refreshUnreadCount(),
      ]);

      expect(inboxFetches, 1);
      expect(NotificationService.unreadCountNotifier.value, 4);

      await NotificationService.markAsRead(10);
      expect(NotificationService.unreadCountNotifier.value, 3);

      await NotificationService.deleteNotification(11);
      expect(NotificationService.unreadCountNotifier.value, 2);

      NotificationService.decrementUnreadCount();
      expect(NotificationService.unreadCountNotifier.value, 1);

      await NotificationService.markAllAsRead();
      expect(NotificationService.unreadCountNotifier.value, 0);

      NotificationService.syncUnreadCount(5);
      await AuthService.clearSession();
      expect(NotificationService.unreadCountNotifier.value, 0);
    },
  );

  testWidgets(
    'NotificationActionButton reacts immediately to unreadCountNotifier updates',
    (tester) async {
      ApiClient.setClientForTesting(
        MockClient((request) async {
          return _jsonResponse({
            'notifications': [],
            'unread_count': 5,
            'types': [
              {'key': 'all', 'label': 'All'},
            ],
            'pagination': {
              'current_page': 1,
              'last_page': 1,
              'has_more': false,
            },
          });
        }),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(actions: const [NotificationActionButton()]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('5'), findsOneWidget);

      NotificationService.syncUnreadCount(2);
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
      expect(find.text('5'), findsNothing);

      NotificationService.syncUnreadCount(0);
      await tester.pump();
      final badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isFalse);
    },
  );

  testWidgets(
    'NotificationsScreen opens notifications immediately with optimistic read sync and rollback on failure',
    (tester) async {
      final read10Completer = Completer<http.Response>();
      final read11Completer = Completer<http.Response>();

      ApiClient.setClientForTesting(
        MockClient((request) {
          if (request.url.path.endsWith('/notifications') &&
              request.method == 'GET') {
            return Future.value(
              _jsonResponse({
                'notifications': [
                  {
                    'id': 10,
                    'title': 'Booking Approved',
                    'message': 'Your reservation is approved.',
                    'type': 'reservation',
                    'link': '/driver/reservations',
                    'read_at': null,
                    'created_at': '2026-11-11T10:00:00Z',
                  },
                  {
                    'id': 11,
                    'title': 'Payment Confirmed',
                    'message': 'Downpayment received.',
                    'type': 'payment',
                    'link': '/driver/reservations',
                    'read_at': null,
                    'created_at': '2026-11-11T09:50:00Z',
                  },
                ],
                'unread_count': 2,
                'types': [
                  {'key': 'all', 'label': 'All'},
                ],
                'pagination': {
                  'current_page': 1,
                  'last_page': 1,
                  'has_more': false,
                },
              }),
            );
          }
          if (request.url.path.endsWith('/notifications/10/read')) {
            return read10Completer.future;
          }
          if (request.url.path.endsWith('/notifications/11/read')) {
            return read11Completer.future;
          }
          return Future.value(_jsonResponse({'message': 'Ok'}));
        }),
      );

      await tester.pumpWidget(const MaterialApp(home: NotificationsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Notifications (2)'), findsOneWidget);

      // Tapping notification 10 opens dialog immediately without waiting for PATCH.
      await tester.tap(find.text('Booking Approved'));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Notifications (1)'), findsOneWidget);
      expect(NotificationService.unreadCountNotifier.value, 1);

      // Complete PATCH /10/read cleanly.
      read10Completer.complete(
        _jsonResponse({
          'message': 'Notification marked as read.',
          'unread_count': 1,
        }),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Notifications (1)'), findsOneWidget);

      // Open notification 11 and simulate server failure -> reverts count & shows error.
      await tester.tap(find.text('Payment Confirmed'));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(NotificationService.unreadCountNotifier.value, 0);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      read11Completer.complete(
        _jsonResponse({'message': 'Server failure'}, statusCode: 500),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifications (1)'), findsOneWidget);
      expect(NotificationService.unreadCountNotifier.value, 1);
      expect(find.text('Server failure'), findsOneWidget);
    },
  );

  test(
    'ConversationService batches ICE signals and refreshes unread notifications on acceptCall',
    () async {
      final postedBodies = <Map<String, dynamic>>[];
      var notificationsFetched = 0;

      ApiClient.setClientForTesting(
        MockClient((request) async {
          if (request.url.path.endsWith('/signals') &&
              request.method == 'POST') {
            postedBodies.add(
              Map<String, dynamic>.from(jsonDecode(request.body) as Map),
            );
            return _jsonResponse({
              'signal_id': 99,
              'signal_ids': [98, 99],
            }, statusCode: 201);
          }
          if (request.url.path.endsWith('/accept') &&
              request.method == 'PATCH') {
            return _jsonResponse({
              'call': {
                'id': 8,
                'reservation_id': 25,
                'caller_id': 3,
                'callee_id': 7,
                'status': 'accepted',
                'is_incoming': true,
              },
            });
          }
          if (request.url.path.endsWith('/notifications') &&
              request.method == 'GET') {
            notificationsFetched += 1;
            return _jsonResponse({
              'notifications': [],
              'unread_count': 0,
              'types': [
                {'key': 'all', 'label': 'All'},
              ],
              'pagination': {
                'current_page': 1,
                'last_page': 1,
                'has_more': false,
              },
            });
          }
          return _jsonResponse({}, statusCode: 404);
        }),
      );

      final call = ReservationCall(
        id: 8,
        reservationId: 25,
        callerId: 3,
        calleeId: 7,
        status: 'ringing',
        isIncoming: true,
      );

      await ConversationService.sendSignalsBatch(call, const []);
      expect(postedBodies, isEmpty);

      await ConversationService.sendSignalsBatch(call, [
        {
          'type': 'ice',
          'payload': {'candidate': 'cand-1'},
        },
        {
          'type': 'ice',
          'payload': {'candidate': 'cand-2'},
        },
      ]);

      expect(postedBodies, hasLength(1));
      expect(postedBodies.single['signals'], hasLength(2));

      NotificationService.syncUnreadCount(1);
      final accepted = await ConversationService.acceptCall(call);
      expect(accepted.status, 'accepted');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(notificationsFetched, 1);
      expect(NotificationService.unreadCountNotifier.value, 0);
    },
  );

  testWidgets(
    'AdminReviewsScreen renders pending async OCR scan status alongside matched and mismatch',
    (tester) async {
      final vehiclePending = AdminVehicleReview.fromJson({
        'id': 1,
        'plate_number': 'ABC 123',
        'plate_scan_status': 'pending',
        'vehicle_type': 'Car',
        'color': 'White',
        'model': 'Vios',
        'verification_status': 'pending',
      });
      expect(vehiclePending.isPlateScanPending, isTrue);

      ApiClient.setClientForTesting(
        MockClient((request) async {
          if (request.url.path.endsWith('/admin/users')) {
            return _jsonResponse({'users': []});
          }
          if (request.url.path.endsWith('/admin/vehicles')) {
            return _jsonResponse({
              'vehicles': [
                {
                  'id': 1,
                  'driver_name': 'Driver One',
                  'driver_email': 'd1@example.com',
                  'plate_number': 'ABC 123',
                  'vehicle_type': 'Car',
                  'make': 'Toyota',
                  'color': 'White',
                  'model': 'Vios',
                  'verification_status': 'pending',
                  'plate_scan_status': 'pending',
                },
                {
                  'id': 2,
                  'driver_name': 'Driver Two',
                  'driver_email': 'd2@example.com',
                  'plate_number': 'DEF 4567',
                  'vehicle_type': 'Car',
                  'make': 'Honda',
                  'color': 'Black',
                  'model': 'City',
                  'verification_status': 'pending',
                  'plate_scan_status': 'matched',
                },
                {
                  'id': 3,
                  'driver_name': 'Driver Three',
                  'driver_email': 'd3@example.com',
                  'plate_number': 'XYZ 999',
                  'vehicle_type': 'Car',
                  'make': 'Ford',
                  'color': 'Blue',
                  'model': 'EcoSport',
                  'verification_status': 'pending',
                  'plate_scan_status': 'mismatch',
                },
              ],
            });
          }
          return _jsonResponse({'parking_spaces': []});
        }),
      );

      await tester.pumpWidget(const MaterialApp(home: AdminReviewsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Vehicles'));
      await tester.pumpAndSettle();

      expect(find.text('Photo scan: OCR scan in progress'), findsOneWidget);
      expect(find.text('Photo scan: plate matched'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text('Photo scan: mismatch detected'), findsOneWidget);
    },
  );
}
