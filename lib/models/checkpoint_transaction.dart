import '../utils/validators.dart';

class CheckpointTransaction {
  CheckpointTransaction({
    required this.id,
    required this.reservationId,
    required String backupReference,
    required this.parkingSpaceId,
    required this.parkingSpaceName,
    required this.driverName,
    required this.lookupMethod,
    required this.eventType,
    required this.wasSuccessful,
    required this.failureReason,
    required this.identifierSuffix,
    required this.createdAt,
  }) : backupReference = backupReference.trim().isEmpty
            ? ''
            : Validators.formatReservationNumber(
                backupReference,
                id: reservationId ?? id,
              );

  final int id;
  final int? reservationId;
  final String backupReference;
  final int? parkingSpaceId;
  final String parkingSpaceName;
  final String driverName;
  final String lookupMethod;
  final String eventType;
  final bool wasSuccessful;
  final String failureReason;
  final String identifierSuffix;
  final DateTime? createdAt;

  String get eventLabel => eventType
      .split('_')
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');

  factory CheckpointTransaction.fromJson(Map<String, dynamic> json) {
    final resId = _nullableInteger(json['reservation_id']);
    final txnId = _integer(json['id']);
    final rawRef = json['backup_reference']?.toString();

    return CheckpointTransaction(
      id: txnId,
      reservationId: resId,
      backupReference: rawRef == null || rawRef.trim().isEmpty
          ? ''
          : Validators.formatReservationNumber(rawRef, id: resId ?? txnId),
      parkingSpaceId: _nullableInteger(json['parking_space_id']),
      parkingSpaceName: json['parking_space_name']?.toString() ?? '',
      driverName: json['driver_name']?.toString() ?? '',
      lookupMethod: json['lookup_method']?.toString() ?? '',
      eventType: json['event_type']?.toString() ?? 'attempt',
      wasSuccessful: json['was_successful'] == true,
      failureReason: json['failure_reason']?.toString() ?? '',
      identifierSuffix: json['identifier_suffix']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  static int _integer(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _nullableInteger(dynamic value) {
    if (value == null) return null;
    return _integer(value);
  }
}
