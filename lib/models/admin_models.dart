import '../config/api_config.dart';

class AdminUserReview {
  const AdminUserReview({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.notes,
    required this.emailVerified,
    required this.idType,
    required this.hasIdentityDocument,
    required this.hasIdentityDocumentBack,
    required this.vehiclesCount,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String status;
  final String notes;
  final bool emailVerified;
  final String idType;
  final bool hasIdentityDocument;
  final bool hasIdentityDocumentBack;
  final int vehiclesCount;
  final DateTime? createdAt;

  factory AdminUserReview.fromJson(Map<String, dynamic> json) {
    return AdminUserReview(
      id: _integer(json['id']),
      name: _text(json['name'], fallback: 'Unknown user'),
      email: _text(json['email']),
      role: _text(json['role']),
      status: _text(json['verification_status'], fallback: 'pending'),
      notes: _text(json['verification_notes']),
      emailVerified: json['email_verified'] == true,
      idType: _text(json['id_type'], fallback: 'Identity document'),
      hasIdentityDocument: json['has_identity_document'] == true,
      hasIdentityDocumentBack: json['has_identity_document_back'] == true,
      vehiclesCount: _integer(json['vehicles_count']),
      createdAt: _date(json['created_at']),
    );
  }
}

class AdminVehicleReview {
  const AdminVehicleReview({
    required this.id,
    required this.driverName,
    required this.driverEmail,
    required this.plateNumber,
    required this.vehicleType,
    required this.make,
    required this.color,
    required this.model,
    required this.status,
    required this.plateScanStatus,
    required this.notes,
    required this.hasPhoto,
    required this.hasPhotoBack,
    required this.reviewerName,
    required this.createdAt,
  });

  final int id;
  final String driverName;
  final String driverEmail;
  final String plateNumber;
  final String vehicleType;
  final String make;
  final String color;
  final String model;
  final String status;
  final String plateScanStatus;
  final String notes;
  final bool hasPhoto;
  final bool hasPhotoBack;
  final String reviewerName;
  final DateTime? createdAt;

  String get description =>
      '$vehicleType | $color ${make.isEmpty ? '' : '$make '}$model';

  factory AdminVehicleReview.fromJson(Map<String, dynamic> json) {
    return AdminVehicleReview(
      id: _integer(json['id']),
      driverName: _text(json['driver_name'], fallback: 'Unknown driver'),
      driverEmail: _text(json['driver_email']),
      plateNumber: _text(json['plate_number']),
      vehicleType: _text(json['vehicle_type']),
      make: _text(json['make']),
      color: _text(json['color']),
      model: _text(json['model']),
      status: _text(json['verification_status'], fallback: 'pending'),
      plateScanStatus: _text(
        json['plate_scan_status'],
        fallback: 'manual_review',
      ),
      notes: _text(json['verification_notes']),
      hasPhoto: json['has_photo'] == true,
      hasPhotoBack: json['has_photo_back'] == true,
      reviewerName: _text(json['reviewer_name']),
      createdAt: _date(json['created_at']),
    );
  }
}

class AdminParkingSpaceReview {
  const AdminParkingSpaceReview({
    required this.id,
    required this.ownerName,
    required this.ownerEmail,
    required this.name,
    required this.address,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    required this.dimensionsSqm,
    required this.vehicleTypes,
    required this.hourlyRates,
    required this.status,
    required this.notes,
    required this.isAvailable,
    required this.operatingHours,
    required this.activeSlots,
    required this.createdAt,
  });

  final int id;
  final String ownerName;
  final String ownerEmail;
  final String name;
  final String address;
  final String description;
  final double? latitude;
  final double? longitude;
  final List<String> imageUrls;
  final double dimensionsSqm;
  final List<String> vehicleTypes;
  final Map<String, double> hourlyRates;
  final String status;
  final String notes;
  final bool isAvailable;
  final String operatingHours;
  final int activeSlots;
  final DateTime? createdAt;

  factory AdminParkingSpaceReview.fromJson(Map<String, dynamic> json) {
    final rates = <String, double>{};
    final rawRates = json['vehicle_hourly_rates'];
    if (rawRates is Map) {
      for (final entry in rawRates.entries) {
        final value = _decimal(entry.value);
        if (value != null) rates[entry.key.toString()] = value;
      }
    }

    return AdminParkingSpaceReview(
      id: _integer(json['id']),
      ownerName: _text(json['owner_name'], fallback: 'Unknown owner'),
      ownerEmail: _text(json['owner_email']),
      name: _text(json['space_name'], fallback: 'Parking space'),
      address: _text(json['address']),
      description: _text(json['description']),
      latitude: _decimal(json['latitude']),
      longitude: _decimal(json['longitude']),
      imageUrls: _strings(json['image_urls'])
          .map((url) => ApiConfig.resolveMediaUrl(url) ?? url)
          .toList(growable: false),
      dimensionsSqm: _decimal(json['dimensions_sqm']) ?? 0,
      vehicleTypes: _strings(json['vehicle_types']),
      hourlyRates: rates,
      status: _text(json['approval_status'], fallback: 'pending'),
      notes: _text(json['admin_notes']),
      isAvailable: json['is_available'] == true,
      operatingHours: _text(json['operating_hours'], fallback: 'Not set'),
      activeSlots: _integer(json['active_slots']),
      createdAt: _date(json['created_at']),
    );
  }
}

class AdminReservationReview {
  const AdminReservationReview({
    required this.id,
    required this.backupReference,
    required this.driverName,
    required this.driverEmail,
    required this.ownerName,
    required this.parkingSpaceName,
    required this.vehicleLabel,
    required this.schedule,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.disputeStatus,
    required this.disputeNotes,
    required this.internalNotes,
    required this.createdAt,
  });

  final int id;
  final String backupReference;
  final String driverName;
  final String driverEmail;
  final String ownerName;
  final String parkingSpaceName;
  final String vehicleLabel;
  final String schedule;
  final String status;
  final String paymentStatus;
  final double? totalAmount;
  final String disputeStatus;
  final String disputeNotes;
  final String internalNotes;
  final DateTime? createdAt;

  factory AdminReservationReview.fromJson(Map<String, dynamic> json) {
    return AdminReservationReview(
      id: _integer(json['id']),
      backupReference: _text(json['backup_reference']),
      driverName: _text(json['driver_name'], fallback: 'Unknown driver'),
      driverEmail: _text(json['driver_email']),
      ownerName: _text(json['owner_name'], fallback: 'Unknown owner'),
      parkingSpaceName: _text(
        json['parking_space_name'],
        fallback: 'Unknown space',
      ),
      vehicleLabel: _text(json['vehicle_label']),
      schedule: _text(json['schedule']),
      status: _text(json['status']),
      paymentStatus: _text(json['payment_status']),
      totalAmount: _decimal(json['total_amount']),
      disputeStatus: _text(json['dispute_status'], fallback: 'normal'),
      disputeNotes: _text(json['dispute_notes']),
      internalNotes: _text(json['admin_internal_notes']),
      createdAt: _date(json['created_at']),
    );
  }
}

class AdminSupportRequest {
  const AdminSupportRequest({
    required this.id,
    required this.name,
    required this.email,
    required this.userRole,
    required this.category,
    required this.subject,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String email;
  final String userRole;
  final String category;
  final String subject;
  final String message;
  final String status;
  final DateTime? createdAt;

  factory AdminSupportRequest.fromJson(Map<String, dynamic> json) {
    return AdminSupportRequest(
      id: _integer(json['id']),
      name: _text(json['name'], fallback: 'Guest'),
      email: _text(json['email']),
      userRole: _text(json['user_role'], fallback: 'guest'),
      category: _text(json['category']),
      subject: _text(json['subject']),
      message: _text(json['message']),
      status: _text(json['status'], fallback: 'open'),
      createdAt: _date(json['created_at']),
    );
  }
}

class AdminAuditLog {
  const AdminAuditLog({
    required this.id,
    required this.action,
    required this.description,
    required this.actorName,
    required this.subjectType,
    required this.subjectId,
    required this.parkingSpaceId,
    required this.parkingSpaceName,
    required this.createdAt,
  });

  final int id;
  final String action;
  final String description;
  final String actorName;
  final String subjectType;
  final int? subjectId;
  final int? parkingSpaceId;
  final String parkingSpaceName;
  final DateTime? createdAt;

  factory AdminAuditLog.fromJson(Map<String, dynamic> json) {
    return AdminAuditLog(
      id: _integer(json['id']),
      action: _text(json['action']),
      description: _text(json['description']),
      actorName: _text(json['actor_name'], fallback: 'System'),
      subjectType: _text(json['subject_type']),
      subjectId: json['subject_id'] == null
          ? null
          : _integer(json['subject_id']),
      parkingSpaceId: json['parking_space_id'] == null
          ? null
          : _integer(json['parking_space_id']),
      parkingSpaceName: _text(
        json['parking_space_name'],
        fallback: 'Platform activity',
      ),
      createdAt: _date(json['created_at']),
    );
  }
}

class AdminQrLog {
  const AdminQrLog({
    required this.id,
    required this.reservationId,
    required this.backupReference,
    required this.parkingSpaceId,
    required this.parkingSpaceName,
    required this.actorName,
    required this.lookupMethod,
    required this.eventType,
    required this.wasSuccessful,
    required this.failureReason,
    required this.identifierSuffix,
    required this.createdAt,
  });

  final int id;
  final int? reservationId;
  final String backupReference;
  final int? parkingSpaceId;
  final String parkingSpaceName;
  final String actorName;
  final String lookupMethod;
  final String eventType;
  final bool wasSuccessful;
  final String failureReason;
  final String identifierSuffix;
  final DateTime? createdAt;

  factory AdminQrLog.fromJson(Map<String, dynamic> json) {
    return AdminQrLog(
      id: _integer(json['id']),
      reservationId: json['reservation_id'] == null
          ? null
          : _integer(json['reservation_id']),
      backupReference: _text(json['backup_reference']),
      parkingSpaceId: json['parking_space_id'] == null
          ? null
          : _integer(json['parking_space_id']),
      parkingSpaceName: _text(
        json['parking_space_name'],
        fallback: 'Unknown space',
      ),
      actorName: _text(json['actor_name'], fallback: 'System'),
      lookupMethod: _text(json['lookup_method']),
      eventType: _text(json['event_type']),
      wasSuccessful: json['was_successful'] == true,
      failureReason: _text(json['failure_reason']),
      identifierSuffix: _text(json['identifier_suffix']),
      createdAt: _date(json['created_at']),
    );
  }
}

class AdminActivityData {
  const AdminActivityData({required this.auditLogs, required this.qrLogs});

  final List<AdminAuditLog> auditLogs;
  final List<AdminQrLog> qrLogs;
}

int _integer(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double? _decimal(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

String _text(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

DateTime? _date(dynamic value) {
  return DateTime.tryParse(value?.toString() ?? '');
}

List<String> _strings(dynamic value) {
  if (value is! List) return const [];
  return value.map((item) => item.toString()).toList(growable: false);
}
