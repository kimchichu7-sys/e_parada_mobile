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

  bool get isAvailable => isOpenNow;

  factory ParkingSpace.fromJson(Map<String, dynamic> json) {
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
      imageUrl: ApiConfig.resolveMediaUrl(json['image_url']?.toString()),
    );
  }
}
