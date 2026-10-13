class RebookSlot {
  const RebookSlot({
    required this.id,
    required this.slotNumber,
    required this.slotLabel,
  });

  final int id;
  final int slotNumber;
  final String slotLabel;

  factory RebookSlot.fromJson(Map<String, dynamic> json) {
    return RebookSlot(
      id: _integer(json['id']),
      slotNumber: _integer(json['slot_number']),
      slotLabel: json['slot_label']?.toString() ?? 'Slot',
    );
  }

  static int _integer(dynamic val) {
    if (val is int) return val;
    return int.tryParse(val?.toString() ?? '') ?? 0;
  }
}

class RebookAlternative {
  const RebookAlternative({
    required this.spaceId,
    required this.spaceName,
    required this.address,
    required this.distanceKm,
    required this.distanceLabel,
    required this.hourlyRate,
    required this.totalSlots,
    required this.availableSlotsCount,
    required this.slots,
    this.imageUrl,
    this.openingTime,
    this.closingTime,
    this.isOpen24Hours = false,
  });

  final int spaceId;
  final String spaceName;
  final String address;
  final double distanceKm;
  final String distanceLabel;
  final double hourlyRate;
  final int totalSlots;
  final int availableSlotsCount;
  final List<RebookSlot> slots;
  final String? imageUrl;
  final String? openingTime;
  final String? closingTime;
  final bool isOpen24Hours;

  factory RebookAlternative.fromJson(Map<String, dynamic> json) {
    final rawSlots = json['slots'];
    final slotList = <RebookSlot>[];
    if (rawSlots is List) {
      for (final s in rawSlots) {
        if (s is Map) {
          slotList.add(RebookSlot.fromJson(Map<String, dynamic>.from(s)));
        }
      }
    }

    return RebookAlternative(
      spaceId: _integer(json['space_id']),
      spaceName: json['space_name']?.toString() ?? 'Parking Space',
      address: json['address']?.toString() ?? '',
      distanceKm: _decimal(json['distance_km']) ?? 0.0,
      distanceLabel: json['distance_label']?.toString() ?? '',
      hourlyRate: _decimal(json['hourly_rate']) ?? 0.0,
      totalSlots: _integer(json['total_slots']),
      availableSlotsCount: _integer(json['available_slots_count']),
      slots: slotList,
      imageUrl: json['image_url']?.toString(),
      openingTime: json['opening_time']?.toString(),
      closingTime: json['closing_time']?.toString(),
      isOpen24Hours: json['is_open_24_hours'] == true,
    );
  }

  static int _integer(dynamic val) {
    if (val is int) return val;
    return int.tryParse(val?.toString() ?? '') ?? 0;
  }

  static double? _decimal(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString());
  }
}

class RebookAlternativesResponse {
  const RebookAlternativesResponse({
    required this.message,
    required this.needsRebook,
    required this.rebookReason,
    this.originalSpace,
    required this.alternatives,
  });

  final String message;
  final bool needsRebook;
  final String rebookReason;
  final Map<String, dynamic>? originalSpace;
  final List<RebookAlternative> alternatives;

  factory RebookAlternativesResponse.fromJson(Map<String, dynamic> json) {
    final altList = <RebookAlternative>[];
    final rawAlts = json['alternatives'];
    if (rawAlts is List) {
      for (final a in rawAlts) {
        if (a is Map) {
          altList.add(RebookAlternative.fromJson(Map<String, dynamic>.from(a)));
        }
      }
    }

    return RebookAlternativesResponse(
      message: json['message']?.toString() ?? '',
      needsRebook: json['needs_rebook'] == true,
      rebookReason: json['rebook_reason']?.toString() ?? '',
      originalSpace: json['original_space'] is Map
          ? Map<String, dynamic>.from(json['original_space'])
          : null,
      alternatives: altList,
    );
  }
}
