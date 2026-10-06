import '../utils/validators.dart';

class OwnerReservation {
  OwnerReservation({
    required this.id,
    required String backupReference,
    required this.driverName,
    required this.plateNumber,
    required this.vehicleType,
    required this.vehicleColor,
    required this.vehicleMake,
    required this.vehicleModel,
    required this.parkingSpaceName,
    required this.slotLabel,
    required this.reservationDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.ownerNotes,
    required this.totalAmount,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.hasPaymentProof,
    required this.timeIn,
    required this.timeOut,
    required this.canCancel,
    required this.canMarkPaid,
    required this.extensionStatus,
    required this.extensionEndDate,
    required this.extensionEndTime,
    required this.extensionReason,
    required this.extensionOwnerNotes,
    required this.hasPendingExtension,
  }) : backupReference =
            Validators.formatReservationNumber(backupReference, id: id);

  final int id;
  final String backupReference;
  final String driverName;
  final String plateNumber;
  final String vehicleType;
  final String vehicleColor;
  final String vehicleMake;
  final String vehicleModel;
  final String parkingSpaceName;
  final String slotLabel;
  final String reservationDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String status;
  final String ownerNotes;
  final double? totalAmount;
  final String paymentStatus;
  final String paymentMethod;
  final bool hasPaymentProof;
  final DateTime? timeIn;
  final DateTime? timeOut;
  final bool canCancel;
  final bool canMarkPaid;
  final String extensionStatus;
  final String extensionEndDate;
  final String extensionEndTime;
  final String extensionReason;
  final String extensionOwnerNotes;
  final bool hasPendingExtension;

  bool get isPending => status == 'pending';

  String get scheduleLabel {
    final end = endDate.isEmpty ? reservationDate : endDate;
    return '$reservationDate $startTime to $end $endTime';
  }

  String get vehicleLabel {
    final details = [
      if (plateNumber.isNotEmpty) plateNumber,
      if (vehicleType.isNotEmpty) vehicleType,
      if (vehicleColor.isNotEmpty) vehicleColor,
      if ('$vehicleMake $vehicleModel'.trim().isNotEmpty)
        '$vehicleMake $vehicleModel'.trim(),
    ];
    return details.isEmpty
        ? 'Vehicle details unavailable'
        : details.join(' | ');
  }

  factory OwnerReservation.fromJson(Map<String, dynamic> json) {
    final driver = _map(json['driver']);
    final vehicle = _map(json['vehicle']);
    final parkingSpace = _map(json['parking_space']);
    final extension = _map(json['extension']);

    final id = _integer(json['id']);
    final rawRef = json['backup_reference']?.toString();
    final ref = Validators.formatReservationNumber(rawRef, id: id);

    return OwnerReservation(
      id: id,
      backupReference: ref,
      driverName: driver['name']?.toString() ?? 'Driver',
      plateNumber: vehicle['plate_number']?.toString() ?? '',
      vehicleType: vehicle['vehicle_type']?.toString() ?? '',
      vehicleColor: vehicle['color']?.toString() ?? '',
      vehicleMake: vehicle['make']?.toString() ?? '',
      vehicleModel: vehicle['model']?.toString() ?? '',
      parkingSpaceName:
          parkingSpace['space_name']?.toString() ?? 'Parking space',
      slotLabel: json['slot_label']?.toString() ?? 'Unassigned slot',
      reservationDate: json['reservation_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      ownerNotes: json['owner_response_notes']?.toString() ?? '',
      totalAmount: _decimal(json['total_amount']),
      paymentStatus: json['payment_status']?.toString() ?? 'unpaid',
      paymentMethod: json['payment_method']?.toString() ?? '',
      hasPaymentProof: json['has_payment_proof'] == true,
      timeIn: DateTime.tryParse(json['time_in']?.toString() ?? ''),
      timeOut: DateTime.tryParse(json['time_out']?.toString() ?? ''),
      canCancel: json['can_cancel'] == true,
      canMarkPaid: json['can_mark_paid'] == true,
      extensionStatus: extension['status']?.toString() ?? '',
      extensionEndDate: extension['end_date']?.toString() ?? '',
      extensionEndTime: extension['end_time']?.toString() ?? '',
      extensionReason: extension['reason']?.toString() ?? '',
      extensionOwnerNotes: extension['owner_notes']?.toString() ?? '',
      hasPendingExtension: json['has_pending_extension'] == true,
    );
  }

  OwnerReservation copyWith({
    String? status,
    String? ownerNotes,
    String? paymentStatus,
    bool? canCancel,
    bool? canMarkPaid,
  }) {
    return OwnerReservation(
      id: id,
      backupReference: backupReference,
      driverName: driverName,
      plateNumber: plateNumber,
      vehicleType: vehicleType,
      vehicleColor: vehicleColor,
      vehicleMake: vehicleMake,
      vehicleModel: vehicleModel,
      parkingSpaceName: parkingSpaceName,
      slotLabel: slotLabel,
      reservationDate: reservationDate,
      endDate: endDate,
      startTime: startTime,
      endTime: endTime,
      status: status ?? this.status,
      ownerNotes: ownerNotes ?? this.ownerNotes,
      totalAmount: totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod,
      hasPaymentProof: hasPaymentProof,
      timeIn: timeIn,
      timeOut: timeOut,
      canCancel: canCancel ?? this.canCancel,
      canMarkPaid: canMarkPaid ?? this.canMarkPaid,
      extensionStatus: extensionStatus,
      extensionEndDate: extensionEndDate,
      extensionEndTime: extensionEndTime,
      extensionReason: extensionReason,
      extensionOwnerNotes: extensionOwnerNotes,
      hasPendingExtension: hasPendingExtension,
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
