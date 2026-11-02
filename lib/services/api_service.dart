import 'package:latlong2/latlong.dart';

import '../models/parking_space.dart';
import 'api_client.dart';

class ApiService {
  static Future<List<ParkingSpace>> fetchParkingSpaces() async {
    final response = await ApiClient.get('parking-spaces');
    ApiClient.requireStatus(response, const {200});

    final body = ApiClient.decodeObject(response);
    final items = body['data'];

    if (items is! List) {
      throw const ApiException(
        'The parking-space list returned by the server is invalid.',
      );
    }

    return items
        .whereType<Map>()
        .map((item) => ParkingSpace.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<ParkingSpace> fetchParkingSpace(int id) async {
    final response = await ApiClient.get('parking-spaces/$id');
    ApiClient.requireStatus(response, const {200});

    final body = ApiClient.decodeObject(response);
    final item = body['data'];

    if (item is! Map) {
      throw const ApiException(
        'The parking-space details returned by the server are invalid.',
      );
    }

    return ParkingSpace.fromJson(Map<String, dynamic>.from(item));
  }

  static Future<LatLng?> geocodeAddress(String query) async {
    try {
      final response = await ApiClient.get('places/geocode?q=${Uri.encodeComponent(query)}');
      if (response.statusCode == 200) {
        final body = ApiClient.decodeObject(response);
        final lat = body['latitude'];
        final lng = body['longitude'];
        if (lat is num && lng is num) {
          return LatLng(lat.toDouble(), lng.toDouble());
        }
      }
    } catch (_) {}
    return null;
  }
}
