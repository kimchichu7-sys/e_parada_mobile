class ReservationSlot {
  const ReservationSlot({
    required this.id,
    required this.label,
    required this.supportedVehicleTypes,
    required this.supportsVehicle,
    required this.isOccupied,
    required this.isAvailable,
  });

  final int id;
  final String label;
  final List<String> supportedVehicleTypes;
  final bool supportsVehicle;
  final bool isOccupied;
  final bool isAvailable;

  factory ReservationSlot.fromJson(Map<String, dynamic> json) {
    return ReservationSlot(
      id: (json['id'] as num?)?.toInt() ?? 0,
      label: json['label']?.toString() ?? 'Slot',
      supportedVehicleTypes: (json['supported_vehicle_types'] as List? ?? [])
          .map((value) => value.toString())
          .toList(growable: false),
      supportsVehicle: json['supports_vehicle'] == true,
      isOccupied: json['is_occupied'] == true,
      isAvailable: json['is_available'] == true,
    );
  }
}

class ReservationAvailability {
  const ReservationAvailability({
    required this.operatingHours,
    required this.hourlyRate,
    required this.slots,
  });

  final String operatingHours;
  final double? hourlyRate;
  final List<ReservationSlot> slots;

  factory ReservationAvailability.fromJson(Map<String, dynamic> json) {
    final parkingSpace = json['parking_space'] is Map
        ? Map<String, dynamic>.from(json['parking_space'] as Map)
        : <String, dynamic>{};
    final slotValues = json['slots'] as List? ?? const [];

    return ReservationAvailability(
      operatingHours:
          parkingSpace['operating_hours']?.toString() ?? 'Hours unavailable',
      hourlyRate: _decimal(parkingSpace['hourly_rate']),
      slots: slotValues
          .whereType<Map>()
          .map(
            (slot) => ReservationSlot.fromJson(Map<String, dynamic>.from(slot)),
          )
          .toList(growable: false),
    );
  }

  static double? _decimal(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
