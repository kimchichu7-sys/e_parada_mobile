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

  bool get isAvailable => isOpenNow;

  int get availableSlotsCount => isAvailable ? 1 : 0;

  double getEffectiveRate({String? vehicleType}) {
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
      name: json['space_name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Closed',
      isOpenNow: json['is_open_now'] == true,
      isOpen24Hours: json['is_open_24_hours'] == true,
      operatingHours:
          json['operating_hours']?.toString() ?? 'Hours unavailable',
      price: json['price']?.toString() ?? 'Rate not set',
      description: json['description']?.toString() ?? '',
      supportedVehicles: (json['supported_vehicles'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(growable: false),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      imageUrl: primaryImage,
      imageUrls: urls,
      maxHeight: (json['max_height'] as num?)?.toDouble() ?? (json['height_clearance'] as num?)?.toDouble(),
      length: (json['length'] as num?)?.toDouble() ?? (json['slot_length'] as num?)?.toDouble(),
      width: (json['width'] as num?)?.toDouble() ?? (json['slot_width'] as num?)?.toDouble(),
    );
  }
}
