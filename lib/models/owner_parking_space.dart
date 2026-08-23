import '../config/api_config.dart';

class OwnerParkingSlot {
  const OwnerParkingSlot({
    required this.id,
    required this.number,
    required this.label,
    required this.supportedVehicleTypes,
    required this.isActive,
  });

  final int id;
  final int number;
  final String label;
  final List<String> supportedVehicleTypes;
  final bool isActive;

  factory OwnerParkingSlot.fromJson(Map<String, dynamic> json) {
    return OwnerParkingSlot(
      id: OwnerParkingSpace.integer(json['id']),
      number: OwnerParkingSpace.integer(json['slot_number']),
      label: json['slot_label']?.toString() ?? 'Slot',
      supportedVehicleTypes: OwnerParkingSpace.stringList(
        json['supported_vehicle_types'],
      ),
      isActive: json['is_active'] == true,
    );
  }
}

class OwnerParkingSpace {
  const OwnerParkingSpace({
    required this.id,
    required this.name,
    required this.address,
    required this.approvalStatus,
    required this.isAvailable,
    required this.isOpenNow,
    required this.operatingHours,
    required this.activeSlotsCount,
    required this.pendingReservationsCount,
    this.latitude,
    this.longitude,
    this.vehicleTypes = const [],
    this.dimensionsSquareMeters,
    this.description = '',
    this.imageUrls = const [],
    this.adminNotes,
    this.isOpen24Hours = true,
    this.openingTime,
    this.closingTime,
    this.overstayGraceMinutes = 30,
    this.abandonedAfterHours = 24,
    this.totalSlots = 0,
    this.hourlyRate,
    this.vehicleHourlyRates = const {},
    this.slots = const [],
  });

  final int id;
  final String name;
  final String address;
  final String approvalStatus;
  final bool isAvailable;
  final bool isOpenNow;
  final String operatingHours;
  final int activeSlotsCount;
  final int pendingReservationsCount;
  final double? latitude;
  final double? longitude;
  final List<String> vehicleTypes;
  final double? dimensionsSquareMeters;
  final String description;
  final List<String> imageUrls;
  final String? adminNotes;
  final bool isOpen24Hours;
  final String? openingTime;
  final String? closingTime;
  final int overstayGraceMinutes;
  final int abandonedAfterHours;
  final int totalSlots;
  final double? hourlyRate;
  final Map<String, double> vehicleHourlyRates;
  final List<OwnerParkingSlot> slots;

  factory OwnerParkingSpace.fromJson(Map<String, dynamic> json) {
    return OwnerParkingSpace(
      id: _integer(json['id']),
      name: json['space_name']?.toString() ?? 'Parking space',
      address: json['address']?.toString() ?? '',
      approvalStatus: json['approval_status']?.toString() ?? 'pending',
      isAvailable: json['is_available'] == true,
      isOpenNow: json['is_open_now'] == true,
      operatingHours: json['operating_hours']?.toString() ?? 'Hours not set',
      activeSlotsCount: _integer(json['active_slots_count']),
      pendingReservationsCount: _integer(json['pending_reservations_count']),
      latitude: _decimal(json['latitude']),
      longitude: _decimal(json['longitude']),
      vehicleTypes: stringList(json['vehicle_types']),
      dimensionsSquareMeters: _decimal(json['dimensions_sqm']),
      description: json['description']?.toString() ?? '',
      imageUrls: stringList(json['image_urls'])
          .map((url) => ApiConfig.resolveMediaUrl(url) ?? url)
          .toList(growable: false),
      adminNotes: json['admin_notes']?.toString(),
      isOpen24Hours: json['is_open_24_hours'] == true,
      openingTime: json['opening_time']?.toString(),
      closingTime: json['closing_time']?.toString(),
      overstayGraceMinutes: _integer(json['overstay_grace_minutes'], 30),
      abandonedAfterHours: _integer(json['abandoned_after_hours'], 24),
      totalSlots: _integer(json['total_slots']),
      hourlyRate: _decimal(json['hourly_rate']),
      vehicleHourlyRates: _rates(json['vehicle_hourly_rates']),
      slots: _maps(
        json['slots'],
      ).map(OwnerParkingSlot.fromJson).toList(growable: false),
    );
  }

  static int _integer(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static int integer(dynamic value, [int fallback = 0]) =>
      _integer(value, fallback);

  static double? _decimal(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static List<String> stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((item) => item.toString()).toList(growable: false);
  }

  static List<Map<String, dynamic>> _maps(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  static Map<String, double> _rates(dynamic value) {
    if (value is! Map) return const {};
    return value.map(
      (key, rate) => MapEntry(key.toString(), _decimal(rate) ?? 0),
    );
  }
}
