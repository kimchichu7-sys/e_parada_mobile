import '../models/vehicle.dart';
import '../models/vehicle_catalog.dart';
import 'api_client.dart';
import 'auth_service.dart';

class VehicleListResult {
  const VehicleListResult({
    required this.vehicles,
    required this.maximum,
    required this.remaining,
  });

  final List<Vehicle> vehicles;
  final int maximum;
  final int remaining;
}

class VehicleService {
  static VehicleCatalog? _catalog;
  static const vehicleTypes = [
    'Motorcycle/E-bicycle',
    'E-tricycle / E-Quads(4 wheels)',
    'Car',
    'SUV/MPV',
    'Pickup/Van',
  ];

  static Future<VehicleCatalog> fetchCatalog({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _catalog != null) return _catalog!;

    final response = await ApiClient.get('vehicle-catalog');
    ApiClient.requireStatus(response, const {200});
    _catalog = VehicleCatalog.fromJson(ApiClient.decodeObject(response));
    return _catalog!;
  }

  static Future<VehicleListResult> fetchVehicles() async {
    final token = await AuthService.requireToken();
    final response = await ApiClient.get(
      'vehicles',
      headers: AuthService.bearerHeaders(token),
    );
    ApiClient.requireStatus(response, const {200});

    final body = ApiClient.decodeObject(response);
    final data = body['data'];
    final meta = body['meta'];

    if (data is! List || meta is! Map) {
      throw const ApiException(
        'The vehicle list returned by the server is invalid.',
      );
    }

    return VehicleListResult(
      vehicles: data
          .whereType<Map>()
          .map((item) => Vehicle.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      maximum: (meta['maximum'] as num?)?.toInt() ?? 3,
      remaining: (meta['remaining'] as num?)?.toInt() ?? 0,
    );
  }

  static Future<String> addVehicle({
    required String plateNumber,
    required String vehicleType,
    required String vehicleMake,
    required String vehicleColor,
    required String vehicleModel,
    required UploadFileData vehiclePhoto,
    required UploadFileData vehiclePhotoBack,
  }) async {
    final token = await AuthService.requireToken();
    final response = await ApiClient.postMultipart(
      'vehicles',
      headers: AuthService.bearerHeaders(token),
      fields: {
        'plate_number': plateNumber,
        'vehicle_type': vehicleType,
        'vehicle_make': vehicleMake,
        'vehicle_color': vehicleColor,
        'vehicle_model': vehicleModel,
        'vehicle_photo_consent': '1',
      },
      files: {
        'vehicle_photo': vehiclePhoto,
        'vehicle_photo_back': vehiclePhotoBack,
      },
    );
    ApiClient.requireStatus(response, const {201});
    return ApiClient.decodeObject(response)['message']?.toString() ??
        'Vehicle submitted for review.';
  }

  static Future<String> deleteRejectedVehicle(int vehicleId) async {
    final token = await AuthService.requireToken();
    final response = await ApiClient.delete(
      'vehicles/$vehicleId',
      headers: AuthService.bearerHeaders(token),
    );
    ApiClient.requireStatus(response, const {200});
    return ApiClient.decodeObject(response)['message']?.toString() ??
        'Vehicle removed.';
  }

  static Future<Map<String, String>> photoHeaders() async {
    final token = await AuthService.requireToken();
    return AuthService.bearerHeaders(token);
  }
}
