class ReservationCall {
  const ReservationCall({
    required this.id,
    required this.reservationId,
    required this.callerId,
    required this.calleeId,
    required this.status,
    required this.isIncoming,
  });

  final int id;
  final int reservationId;
  final int callerId;
  final int calleeId;
  final String status;
  final bool isIncoming;

  bool get isActive => status == 'ringing' || status == 'accepted';

  factory ReservationCall.fromJson(Map<String, dynamic> json) {
    return ReservationCall(
      id: (json['id'] as num).toInt(),
      reservationId: (json['reservation_id'] as num).toInt(),
      callerId: (json['caller_id'] as num).toInt(),
      calleeId: (json['callee_id'] as num).toInt(),
      status: json['status']?.toString() ?? 'ended',
      isIncoming: json['is_incoming'] == true,
    );
  }
}
