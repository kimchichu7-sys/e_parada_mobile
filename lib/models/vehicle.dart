class Vehicle {
  final int id;
  final String plateNumber;
  final String vehicleType;
  final String make;
  final String color;
  final String model;
  final String verificationStatus;
  final String plateScanStatus;
  final String? verificationNotes;
  final String photoUrl;
  final String photoBackUrl;
  final String? orPhotoUrl;
  final String? crPhotoUrl;
  final String? authorizationLetterUrl;
  final DateTime? registrationExpiry;
  final bool isOwnerDriving;
  final String? registeredOwnerName;
  final double? length;
  final double? width;
  final double? height;

  const Vehicle({
    required this.id,
    required this.plateNumber,
    required this.vehicleType,
    required this.make,
    required this.color,
    required this.model,
    required this.verificationStatus,
    required this.plateScanStatus,
    required this.photoUrl,
    required this.photoBackUrl,
    this.orPhotoUrl,
    this.crPhotoUrl,
    this.authorizationLetterUrl,
    this.registrationExpiry,
    this.isOwnerDriving = true,
    this.registeredOwnerName,
    this.verificationNotes,
    this.length,
    this.width,
    this.height,
  });

  bool get isApproved => verificationStatus == 'approved';
  bool get isPending => verificationStatus == 'pending';
  bool get isRejected => verificationStatus == 'rejected';

  String get dimensionSummary {
    if (length == null || width == null) return '';
    if (height != null) {
      return '${length!.toStringAsFixed(1)}m × ${width!.toStringAsFixed(1)}m × ${height!.toStringAsFixed(1)}m (L×W×H)';
    }
    return '${length!.toStringAsFixed(1)}m × ${width!.toStringAsFixed(1)}m (L×W)';
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    DateTime? parsedExpiry;
    final expiryRaw = json['registration_expiry']?.toString();
    if (expiryRaw != null && expiryRaw.isNotEmpty) {
      parsedExpiry = DateTime.tryParse(expiryRaw);
    }

    final isOwnerVal = json['is_owner_driving'];
    final bool parsedIsOwner = isOwnerVal is bool
        ? isOwnerVal
        : (isOwnerVal == null || isOwnerVal.toString() == '1' || isOwnerVal.toString().toLowerCase() == 'true');

    return Vehicle(
      id: (json['id'] as num).toInt(),
      plateNumber: json['plate_number']?.toString() ?? '',
      vehicleType: json['vehicle_type']?.toString() ?? '',
      make: json['make']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      verificationStatus: json['verification_status']?.toString() ?? 'pending',
      plateScanStatus: json['plate_scan_status']?.toString() ?? 'manual_review',
      verificationNotes: json['verification_notes']?.toString(),
      photoUrl: json['photo_url']?.toString() ?? '',
      photoBackUrl: json['photo_back_url']?.toString() ?? '',
      orPhotoUrl: json['or_photo_url']?.toString(),
      crPhotoUrl: json['cr_photo_url']?.toString(),
      authorizationLetterUrl: json['authorization_letter_url']?.toString(),
      registrationExpiry: parsedExpiry,
      isOwnerDriving: parsedIsOwner,
      registeredOwnerName: json['registered_owner_name']?.toString(),
      length: (json['length'] as num?)?.toDouble() ?? (json['length_m'] as num?)?.toDouble(),
      width: (json['width'] as num?)?.toDouble() ?? (json['width_m'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble() ?? (json['height_m'] as num?)?.toDouble(),
    );
  }
}
