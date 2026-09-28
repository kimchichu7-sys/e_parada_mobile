import 'package:e_parada_mobile/models/reservation_call.dart';
import 'package:e_parada_mobile/models/reservation_conversation.dart';
import 'package:e_parada_mobile/screens/reservation_conversation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a private reservation conversation without phone details', () {
    final conversation = ReservationConversation.fromJson({
      'reservation': {
        'id': 25,
        'backup_reference': 'RES-25',
        'status': 'approved',
        'parking_space_name': 'Calamba Central Parking',
        'other_party': {
          'id': 7,
          'name': 'Parking Provider',
          'role': 'parking_owner',
        },
        'can_call': true,
      },
      'messages': [
        {
          'id': 4,
          'sender_id': 3,
          'sender_name': 'Driver One',
          'body': 'I am approaching the entrance.',
          'created_at': '2026-08-20T10:30:00+08:00',
        },
      ],
    });

    expect(conversation.reference, 'RES-75517348');
    expect(conversation.otherPartyName, 'Parking Provider');
    expect(conversation.canCall, isTrue);
    expect(conversation.messages, hasLength(1));
    expect(conversation.messages.single.body, contains('entrance'));
  });

  test('recognizes incoming and inactive calls', () {
    final ringing = ReservationCall.fromJson({
      'id': 8,
      'reservation_id': 25,
      'caller_id': 3,
      'callee_id': 7,
      'status': 'ringing',
      'is_incoming': true,
    });
    final ended = ReservationCall.fromJson({
      'id': 9,
      'reservation_id': 25,
      'caller_id': 3,
      'callee_id': 7,
      'status': 'ended',
      'is_incoming': false,
    });

    expect(ringing.isIncoming, isTrue);
    expect(ringing.isActive, isTrue);
    expect(ended.isActive, isFalse);
  });

  testWidgets('ReservationConversationScreen renders quick action chips', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ReservationConversationScreen(
          reservationId: 25,
          otherPartyName: 'Parking Owner Juan',
        ),
      ),
    );
    await tester.pump();

    // Check that quick chips are available
    expect(find.text("🚗 I've arrived at the gate"), findsOneWidget);
    expect(find.text("📍 Which bay should I park in?"), findsOneWidget);
    expect(find.text("⏳ Running 10 mins late"), findsOneWidget);

    // Tap quick chip
    await tester.tap(find.text("🚗 I've arrived at the gate"));
    await tester.pump();

    expect(find.text("🚗 I've arrived at the gate"), findsWidgets);

    // Verify AppBar Call button and empty state call button
    expect(find.text('Call'), findsOneWidget);
    expect(find.byIcon(Icons.phone_in_talk_rounded), findsWidgets);
  });
}
