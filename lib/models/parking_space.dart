import '../config/api_config.dart';

class ParkingSpace {
  const ParkingSpace({
    required this.id,
    required this.name,
    required this.address,
    required this.status,
    required this.isOpenNow,
    required this.isOpen24Hours,
    required this.operatingHours,
    required this.price,
    required this.description,
    required this.supportedVehicles,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.imageUrls = const [],
    this.maxHeight,
    this.length,
    this.width,
    this.hourlyRate,
    this.lowestHourlyRate,
    this.vehicleHourlyRates = const {},
    this.totalSlots = 1,
    this.availableSlots = 1,
    this.isSoldOut = false,
    this.openingTime,
    this.closingTime,
  });

  final int id;
  final String name;
  final String address;
  final String status;
  final bool isOpenNow;
  final bool isOpen24Hours;
  final String operatingHours;
  final String price;
  final String description;
  final List<String> supportedVehicles;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final List<String> imageUrls;
  final double? maxHeight;
  final double? length;
  final double? width;
  final double? hourlyRate;
  final double? lowestHourlyRate;
  final Map<String, double> vehicleHourlyRates;
  final int totalSlots;
  final int availableSlots;
  final bool isSoldOut;
  final String? openingTime;
  final String? closingTime;

  bool get isClosed => !isOpenNow && !isOpen24Hours;
  bool get isAvailable => !isSoldOut;

  int get availableSlotsCount => availableSlots;

  double getEffectiveRate({String? vehicleType}) {
    // 1. If a specific vehicle type is selected
    if (vehicleType != null &&
        vehicleType.isNotEmpty &&
        vehicleType.trim().toLowerCase() != 'all' &&
        vehicleType.trim().toLowerCase() != 'all vehicle types') {
      final normalizedQuery = vehicleType.trim().toLowerCase();

      // Direct / exact key check
      for (final entry in vehicleHourlyRates.entries) {
        if (entry.key.trim().toLowerCase() == normalizedQuery && entry.value > 0) {
          return entry.value;
        }
      }

      // Substring / partial key check (e.g. "SUV" <-> "SUV/MPV", "Car" <-> "Car/Sedan")
      for (final entry in vehicleHourlyRates.entries) {
        final k = entry.key.trim().toLowerCase();
        if ((k.contains(normalizedQuery) || normalizedQuery.contains(k)) && entry.value > 0) {
          return entry.value;
        }
      }
    }

    // 2. If "All vehicle types" or not found: Return the lowest price for this space
    if (lowestHourlyRate != null && lowestHourlyRate! > 0) {
      return lowestHourlyRate!;
    }

    if (vehicleHourlyRates.isNotEmpty) {
      final validRates = vehicleHourlyRates.values.where((r) => r > 0).toList();
      if (validRates.isNotEmpty) {
        return validRates.reduce((a, b) => a < b ? a : b);
      }
    }

    if (hourlyRate != null && hourlyRate! > 0) {
      return hourlyRate!;
    }

    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(price);
    if (match != null) {
      return double.tryParse(match.group(1) ?? '') ?? 0.0;
    }

    return 0.0;
  }

  String get clearanceSummary {
    if (maxHeight == null) return '';
    return 'Max Height Clearance: ${maxHeight!.toStringAsFixed(1)}m';
  }

  factory ParkingSpace.fromJson(Map<String, dynamic> json) {
    final urls = <String>[];

    String? extractUrl(dynamic val) {
      if (val == null) return null;
      if (val is String) {
        final trimmed = val.trim();
        return trimmed.isNotEmpty ? trimmed : null;
      }
      if (val is Map) {
        final candidate = val['url'] ??
            val['path'] ??
            val['image_url'] ??
            val['photo_url'] ??
            val['file_path'] ??
            val['picture_url'] ??
            val['thumbnail_url'];
        if (candidate != null) {
          final trimmed = candidate.toString().trim();
          return trimmed.isNotEmpty ? trimmed : null;
        }
      }
      return null;
    }

    void addCandidate(dynamic val) {
      final raw = extractUrl(val);
      if (raw != null) {
        final resolved = ApiConfig.resolveMediaUrl(raw);
        if (resolved != null && resolved.isNotEmpty && !urls.contains(resolved)) {
          urls.add(resolved);
        }
      }
    }

    final listKeys = [
      'image_urls',
      'images',
      'photos',
      'photo_urls',
      'pictures',
      'parking_images',
      'space_images',
      'space_photos',
      'media',
      'attachments',
    ];

    for (final key in listKeys) {
      if (json[key] is List) {
        for (final item in json[key] as List) {
          addCandidate(item);
        }
      }
    }

    final singleKeys = [
      'image_url',
      'photo_url',
      'photo',
      'image',
      'picture',
      'parking_image',
      'thumbnail',
      'thumbnail_url',
      'cover_image',
      'space_image',
      'space_photo',
      'file_path',
      'path',
      'url',
    ];

    for (final key in singleKeys) {
      if (json[key] != null) {
        addCandidate(json[key]);
      }
    }

    final primaryImage = urls.isNotEmpty ? urls.first : null;

    return ParkingSpace(
      id: _integer(json['id']),
      name: json['space_name']?.toString() ?? json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Closed',
      isOpenNow: json['is_open_now'] == true,
      isOpen24Hours: json['is_open_24_hours'] == true,
      operatingHours:
          json['operating_hours']?.toString() ?? 'Hours unavailable',
      price: json['price']?.toString() ?? 'Rate not set',
      description: json['description']?.toString() ?? '',
      supportedVehicles: () {
        final raw = (json['supported_vehicles'] as List<dynamic>? ?? [])
            .map((item) => item.toString().trim());
        final cleaned = <String>{};
        for (final item in raw) {
          final normalized = item.toLowerCase() == 'motorcycle/e-bicycle' ? 'Motorcycle' : item;
          final lower = normalized.toLowerCase();
          if (lower.startsWith('e-') ||
              lower.contains('e-tricycle') ||
              lower.contains('e-quad') ||
              lower.contains('e-bicycle') ||
              lower.contains('e-bike') ||
              lower.contains('e-trike') ||
              lower.contains('e-vehicle')) {
            continue;
          }
          if (normalized.isNotEmpty) {
            cleaned.add(normalized);
          }
        }
        return cleaned.toList(growable: false);
      }(),
      latitude: _decimal(json['latitude']),
      longitude: _decimal(json['longitude']),
      imageUrl: primaryImage,
      imageUrls: urls,
      maxHeight: _decimal(json['max_height'] ?? json['height_clearance']),
      length: _decimal(json['length'] ?? json['slot_length']),
      width: _decimal(json['width'] ?? json['slot_width']),
      hourlyRate: _decimal(json['hourly_rate'] ?? json['rate']),
      lowestHourlyRate: _decimal(json['lowest_hourly_rate'] ?? json['lowest_rate']),
      totalSlots: _integer(json['total_slots'], 1),
      availableSlots: _integer(json['available_slots'] ?? json['available_slots_count'], 1),
      isSoldOut: json['is_sold_out'] == true,
      openingTime: json['opening_time']?.toString(),
      closingTime: json['closing_time']?.toString(),
      vehicleHourlyRates: () {
        final rates = <String, double>{};
        if (json['vehicle_hourly_rates'] is Map) {
          (json['vehicle_hourly_rates'] as Map).forEach((k, v) {
            if (v != null) {
              final parsed = (v is num) ? v.toDouble() : double.tryParse(v.toString());
              if (parsed != null && parsed >= 0) {
                rates[k.toString().trim()] = parsed;
              }
            }
          });
        }
        return rates;
      }(),
    );
  }

  static double? _decimal(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim());
  }

  static int _integer(dynamic value, [int fallback = 0]) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().trim()) ?? fallback;
  }
}
