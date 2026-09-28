import '../utils/validators.dart';

class DriverReservation {
  DriverReservation({
    required this.id,
    this.parkingSpaceId,
    required String backupReference,
    required this.qrCode,
    required this.parkingSpaceName,
    required this.parkingSpaceAddress,
    required this.ownerName,
    required this.slotLabel,
    required this.vehicleId,
    required this.plateNumber,
    required this.vehicleType,
    required this.reservationDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.ownerNotes,
    required this.totalHours,
    required this.totalAmount,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.timeIn,
    required this.timeOut,
    required this.feedbackRating,
    required this.feedbackComment,
    required this.extensionStatus,
    required this.extensionEndDate,
    required this.extensionEndTime,
    required this.extensionReason,
    required this.extensionOwnerNotes,
    required this.overstayStatus,
    required this.overstayMinutes,
    required this.overstayAmount,
    required this.canCancel,
    required this.canReschedule,
    required this.canExtend,
    required this.canSubmitPayment,
    required this.canSubmitFeedback,
  }) : backupReference =
            Validators.formatReservationNumber(backupReference, id: id);

  final int id;
  final int? parkingSpaceId;
  final String backupReference;
  final String qrCode;
  final String parkingSpaceName;
  final String parkingSpaceAddress;
  final String ownerName;
  final String slotLabel;
  final int vehicleId;
  final String plateNumber;
  final String vehicleType;
  final String reservationDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String status;
  final String ownerNotes;
  final double? totalHours;
  final double? totalAmount;
  final String paymentStatus;
  final String paymentMethod;
  final DateTime? timeIn;
  final DateTime? timeOut;
  final int? feedbackRating;
  final String feedbackComment;
  final String extensionStatus;
  final String extensionEndDate;
  final String extensionEndTime;
  final String extensionReason;
  final String extensionOwnerNotes;
  final String overstayStatus;
  final int overstayMinutes;
  final double overstayAmount;
  final bool canCancel;
  final bool canReschedule;
  final bool canExtend;
  final bool canSubmitPayment;
  final bool canSubmitFeedback;

  String get scheduleLabel =>
      '$reservationDate $startTime to $endDate $endTime';

  DateTime? get scheduledStartDateTime {
    if (reservationDate.isEmpty || startTime.isEmpty) return null;
    final parsedDate = DateTime.tryParse(reservationDate);
    if (parsedDate == null) return null;
    final parts = startTime.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '0') ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return DateTime(parsedDate.year, parsedDate.month, parsedDate.day, hour, minute);
  }

  DateTime? get scheduledEndDateTime {
    final dateStr = endDate.isNotEmpty ? endDate : reservationDate;
    if (dateStr.isEmpty || endTime.isEmpty) return null;
    final parsedDate = DateTime.tryParse(dateStr);
    if (parsedDate == null) return null;
    final parts = endTime.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '0') ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return DateTime(parsedDate.year, parsedDate.month, parsedDate.day, hour, minute);
  }

  bool get hasCredential => qrCode.isNotEmpty || backupReference.isNotEmpty;
  bool get extensionPending => extensionStatus == 'pending';

  factory DriverReservation.fromJson(Map<String, dynamic> json) {
    final parkingSpace = _map(json['parking_space']);
    final directOwner = _map(json['owner']);
    final parkingOwner = _map(parkingSpace['owner']);
    final owner = directOwner.isNotEmpty ? directOwner : parkingOwner;
    final slot = _map(json['slot']);
    final vehicle = _map(json['vehicle']);
    final feedback = _map(json['feedback']);
    final extension = _map(json['extension']);
    final overstay = _map(json['overstay']);
    final actions = _map(json['actions']);

    final id = _integer(json['id']);
    final rawRef = json['backup_reference']?.toString();
    final ref = Validators.formatReservationNumber(rawRef, id: id);

    return DriverReservation(
      id: id,
      parkingSpaceId: _integer(parkingSpace['id'] ?? json['parking_space_id']) > 0
          ? _integer(parkingSpace['id'] ?? json['parking_space_id'])
          : null,
      backupReference: ref,
      qrCode: json['qr_code']?.toString() ?? '',
      parkingSpaceName: parkingSpace['name']?.toString() ??
          json['parking_space_name']?.toString() ??
          'Parking space',
      parkingSpaceAddress: parkingSpace['address']?.toString() ??
          json['parking_space_address']?.toString() ??
          '',
      ownerName:
          owner['name']?.toString() ??
          parkingSpace['owner_name']?.toString() ??
          json['owner_name']?.toString() ??
          'Parking provider',
      slotLabel: slot['label']?.toString() ??
          json['slot_label']?.toString() ??
          'Unassigned slot',
      vehicleId: _integer(vehicle['id'] ?? json['vehicle_id']),
      plateNumber: vehicle['plate_number']?.toString() ??
          json['plate_number']?.toString() ??
          '',
      vehicleType: vehicle['vehicle_type']?.toString() ??
          json['vehicle_type']?.toString() ??
          '',
      reservationDate: json['reservation_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      ownerNotes: json['owner_response_notes']?.toString() ?? '',
      totalHours: _decimal(json['total_hours']),
      totalAmount: _decimal(json['total_amount']),
      paymentStatus: json['payment_status']?.toString() ?? 'unpaid',
      paymentMethod: json['payment_method']?.toString() ?? '',
      timeIn: DateTime.tryParse(json['time_in']?.toString() ?? ''),
      timeOut: DateTime.tryParse(json['time_out']?.toString() ?? ''),
      feedbackRating: feedback.isEmpty ? null : _integer(feedback['rating']),
      feedbackComment: feedback['comment']?.toString() ?? '',
      extensionStatus: extension['status']?.toString() ?? '',
      extensionEndDate: extension['end_date']?.toString() ?? '',
      extensionEndTime: extension['end_time']?.toString() ?? '',
      extensionReason: extension['reason']?.toString() ?? '',
      extensionOwnerNotes: extension['owner_notes']?.toString() ?? '',
      overstayStatus: overstay['status']?.toString() ?? 'normal',
      overstayMinutes: _integer(overstay['minutes']),
      overstayAmount: _decimal(overstay['amount']) ?? 0,
      canCancel: actions['can_cancel'] == true,
      canReschedule: actions['can_reschedule'] == true,
      canExtend: actions['can_extend'] == true,
      canSubmitPayment: actions['can_submit_payment'] == true,
      canSubmitFeedback: actions['can_submit_feedback'] == true,
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

  static double? _decimal(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
