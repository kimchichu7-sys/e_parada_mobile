import '../utils/validators.dart';
import 'conversation_message.dart';
import 'reservation_call.dart';

class ReservationConversation {
  ReservationConversation({
    required this.reservationId,
    required String reference,
    required this.status,
    required this.parkingSpaceName,
    required this.otherPartyId,
    required this.otherPartyName,
    required this.otherPartyRole,
    required this.canCall,
    required this.messages,
    this.activeCall,
  }) : reference =
            Validators.formatReservationNumber(reference, id: reservationId);

  final int reservationId;
  final String reference;
  final String status;
  final String parkingSpaceName;
  final int otherPartyId;
  final String otherPartyName;
  final String otherPartyRole;
  final bool canCall;
  final List<ConversationMessage> messages;
  final ReservationCall? activeCall;

  factory ReservationConversation.fromJson(Map<String, dynamic> json) {
    final reservation = Map<String, dynamic>.from(json['reservation'] as Map);
    final otherParty = Map<String, dynamic>.from(
      reservation['other_party'] as Map,
    );
    final rawMessages = json['messages'] as List? ?? const [];
    final rawCall = json['call'];

    final resId = (reservation['id'] as num).toInt();
    return ReservationConversation(
      reservationId: resId,
      reference: Validators.formatReservationNumber(
        reservation['backup_reference']?.toString(),
        id: resId,
      ),
      status: reservation['status']?.toString() ?? '',
      parkingSpaceName:
          reservation['parking_space_name']?.toString() ?? 'Parking space',
      otherPartyId: (otherParty['id'] as num).toInt(),
      otherPartyName: otherParty['name']?.toString() ?? 'E-Parada user',
      otherPartyRole: otherParty['role']?.toString() ?? '',
      canCall: reservation['can_call'] == true,
      activeCall: rawCall is Map
          ? ReservationCall.fromJson(Map<String, dynamic>.from(rawCall))
          : null,
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
