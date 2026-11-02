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
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    this.imageUrls = const [],
    this.maxHeight,
    this.length,
    this.width,
    this.hourlyRate,
    this.lowestHourlyRate,
    this.vehicleHourlyRates = const {},
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

  bool get isAvailable => isOpenNow;

  int get availableSlotsCount => isAvailable ? 1 : 0;

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
      id: (json['id'] as num?)?.toInt() ?? 0,
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
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      imageUrl: primaryImage,
      imageUrls: urls,
      maxHeight: (json['max_height'] as num?)?.toDouble() ?? (json['height_clearance'] as num?)?.toDouble(),
      length: (json['length'] as num?)?.toDouble() ?? (json['slot_length'] as num?)?.toDouble(),
      width: (json['width'] as num?)?.toDouble() ?? (json['slot_width'] as num?)?.toDouble(),
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble() ?? (json['rate'] as num?)?.toDouble(),
      lowestHourlyRate: (json['lowest_hourly_rate'] as num?)?.toDouble() ?? (json['lowest_rate'] as num?)?.toDouble(),
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
}
