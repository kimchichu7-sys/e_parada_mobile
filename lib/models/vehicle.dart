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
      length: (json['length'] as num?)?.toDouble() ?? (json['length_m'] as num?)?.toDouble(),
      width: (json['width'] as num?)?.toDouble() ?? (json['width_m'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble() ?? (json['height_m'] as num?)?.toDouble(),
    );
  }
}
