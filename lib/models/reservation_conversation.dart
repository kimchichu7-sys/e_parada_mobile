import 'conversation_message.dart';

class ReservationConversation {
  const ReservationConversation({
    required this.reservationId,
    required this.reference,
    required this.status,
    required this.parkingSpaceName,
    required this.otherPartyId,
    required this.otherPartyName,
    required this.otherPartyRole,
    required this.canCall,
    required this.messages,
  });

  final int reservationId;
  final String reference;
  final String status;
  final String parkingSpaceName;
  final int otherPartyId;
  final String otherPartyName;
  final String otherPartyRole;
  final bool canCall;
  final List<ConversationMessage> messages;

  factory ReservationConversation.fromJson(Map<String, dynamic> json) {
    final reservation = Map<String, dynamic>.from(json['reservation'] as Map);
    final otherParty = Map<String, dynamic>.from(
      reservation['other_party'] as Map,
    );
    final rawMessages = json['messages'] as List? ?? const [];

    return ReservationConversation(
      reservationId: (reservation['id'] as num).toInt(),
      reference: reservation['backup_reference']?.toString() ?? '',
      status: reservation['status']?.toString() ?? '',
      parkingSpaceName:
          reservation['parking_space_name']?.toString() ?? 'Parking space',
      otherPartyId: (otherParty['id'] as num).toInt(),
      otherPartyName: otherParty['name']?.toString() ?? 'E-Parada user',
      otherPartyRole: otherParty['role']?.toString() ?? '',
      canCall: reservation['can_call'] == true,
      messages: rawMessages
          .whereType<Map>()
          .map(
            (item) =>
                ConversationMessage.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }
}
