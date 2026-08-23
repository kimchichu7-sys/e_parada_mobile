import 'package:e_parada_mobile/models/reservation_call.dart';
import 'package:e_parada_mobile/models/reservation_conversation.dart';
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

    expect(conversation.reference, 'RES-25');
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
}
