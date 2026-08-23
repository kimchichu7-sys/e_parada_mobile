import 'dart:typed_data';

import '../models/checkpoint_transaction.dart';
import '../models/owner_parking_space.dart';
import '../models/owner_reservation.dart';
import 'api_client.dart';
import 'auth_service.dart';

class OwnerCheckpointData {
  const OwnerCheckpointData({
    required this.parkingSpaces,
    required this.transactions,
  });

  final List<OwnerParkingSpace> parkingSpaces;
  final List<CheckpointTransaction> transactions;
}

class CheckpointResult {
  const CheckpointResult({
    required this.message,
    required this.eventType,
    required this.reservation,
    required this.transactions,
  });

  final String message;
  final String eventType;
  final OwnerReservation reservation;
  final List<CheckpointTransaction> transactions;
}

class OwnerOperationsService {
  static const vehicleTypes = [
    'Motorcycle/E-bicycle',
    'E-tricycle / E-Quads(4 wheels)',
    'Car',
    'SUV/MPV',
    'Pickup/Van',
  ];

  static Future<List<OwnerParkingSpace>> fetchSpaces() async {
    final response = await ApiClient.get(
      'owner/parking-spaces',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    final body = ApiClient.decodeObject(response);
    return _list(
      body['parking_spaces'],
    ).map(OwnerParkingSpace.fromJson).toList(growable: false);
  }

  static Future<OwnerParkingSpace> fetchSpace(int parkingSpaceId) async {
    final response = await ApiClient.get(
      'owner/parking-spaces/$parkingSpaceId',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    final data = ApiClient.decodeObject(response)['parking_space'];
    if (data is! Map) {
      throw const ApiException('The parking-space details are incomplete.');
    }
    return OwnerParkingSpace.fromJson(Map<String, dynamic>.from(data));
  }

  static Future<String> saveSpace({
    int? parkingSpaceId,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required List<String> vehicleTypes,
    required double dimensionsSquareMeters,
    required String description,
    required bool isOpen24Hours,
    String? openingTime,
    String? closingTime,
    required int overstayGraceMinutes,
    required int abandonedAfterHours,
    required List<List<String>> slotVehicleTypes,
    required List<UploadFileData> images,
  }) async {
    final fields = <String, String>{
      'space_name': name,
      'address': address,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'dimensions_sqm': dimensionsSquareMeters.toString(),
      'description': description,
      'is_open_24_hours': isOpen24Hours ? '1' : '0',
      if (!isOpen24Hours) 'opening_time': openingTime ?? '',
      if (!isOpen24Hours) 'closing_time': closingTime ?? '',
      'overstay_grace_minutes': overstayGraceMinutes.toString(),
      'abandoned_after_hours': abandonedAfterHours.toString(),
      'total_slots': slotVehicleTypes.length.toString(),
    };

    for (var index = 0; index < vehicleTypes.length; index++) {
      fields['vehicle_types[$index]'] = vehicleTypes[index];
    }
    for (var slot = 0; slot < slotVehicleTypes.length; slot++) {
      for (var type = 0; type < slotVehicleTypes[slot].length; type++) {
        fields['slot_vehicle_types[$slot][$type]'] =
            slotVehicleTypes[slot][type];
      }
    }

    final response = await ApiClient.postMultipart(
      parkingSpaceId == null
          ? 'owner/parking-spaces'
          : 'owner/parking-spaces/$parkingSpaceId',
      headers: await _headers(),
      fields: fields,
      fileParts: images
          .map((image) => UploadFilePart(field: 'images[]', file: image))
          .toList(growable: false),
    );
    ApiClient.requireStatus(
      response,
      parkingSpaceId == null ? const {201} : const {200},
    );
    return ApiClient.decodeObject(response)['message']?.toString() ??
        'Parking space saved.';
  }

  static Future<String> deleteSpace(int parkingSpaceId) async {
    final response = await ApiClient.delete(
      'owner/parking-spaces/$parkingSpaceId',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    return ApiClient.decodeObject(response)['message']?.toString() ??
        'Parking space deleted.';
  }

  static Future<List<OwnerReservation>> fetchReservations({
    String? status,
  }) async {
    final suffix = status == null || status.isEmpty ? '' : '?status=$status';
    final response = await ApiClient.get(
      'owner/reservations$suffix',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    final body = ApiClient.decodeObject(response);
    return _list(
      body['reservations'],
    ).map(OwnerReservation.fromJson).toList(growable: false);
  }

  static Future<String> approveReservation(int reservationId, {String? notes}) {
    return _reservationAction(
      '$reservationId/approve',
      body: {'owner_response_notes': notes ?? ''},
    );
  }

  static Future<String> rejectReservation(
    int reservationId, {
    required String notes,
  }) {
    return _reservationAction(
      '$reservationId/reject',
      body: {'owner_response_notes': notes},
    );
  }

  static Future<String> cancelReservation(int reservationId, {String? reason}) {
    return _reservationAction(
      '$reservationId/cancel',
      body: {'cancellation_reason': reason ?? ''},
    );
  }

  static Future<String> markPaid(
    int reservationId, {
    required String paymentMethod,
  }) {
    return _reservationAction(
      '$reservationId/mark-paid',
      body: {'payment_method': paymentMethod},
    );
  }

  static Future<String> approveExtension(int reservationId, {String? notes}) {
    return _reservationAction(
      '$reservationId/extension/approve',
      body: {'extension_owner_notes': notes ?? ''},
    );
  }

  static Future<String> rejectExtension(
    int reservationId, {
    required String notes,
  }) {
    return _reservationAction(
      '$reservationId/extension/reject',
      body: {'extension_owner_notes': notes},
    );
  }

  static Future<Uint8List> fetchPaymentProof(int reservationId) async {
    final response = await ApiClient.get(
      'owner/reservations/$reservationId/payment-proof',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    return response.bodyBytes;
  }

  static Future<OwnerCheckpointData> fetchCheckpointData() async {
    final response = await ApiClient.get(
      'owner/checkpoints',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    final body = ApiClient.decodeObject(response);

    return OwnerCheckpointData(
      parkingSpaces: _list(
        body['parking_spaces'],
      ).map(OwnerParkingSpace.fromJson).toList(growable: false),
      transactions: _list(
        body['transaction_logs'],
      ).map(CheckpointTransaction.fromJson).toList(growable: false),
    );
  }

  static Future<CheckpointResult> validateCheckpoint({
    required int parkingSpaceId,
    required String credential,
  }) async {
    final response = await ApiClient.postJson(
      'owner/checkpoints/validate',
      headers: await _headers(),
      body: {'parking_space_id': parkingSpaceId, 'credential': credential},
    );
    ApiClient.requireStatus(response, const {200});
    final body = ApiClient.decodeObject(response);
    final reservationData = body['reservation'];

    if (reservationData is! Map) {
      throw const ApiException('The checkpoint result is incomplete.');
    }

    return CheckpointResult(
      message: body['message']?.toString() ?? 'Checkpoint validated.',
      eventType: body['event_type']?.toString() ?? 'validated',
      reservation: OwnerReservation.fromJson(
        Map<String, dynamic>.from(reservationData),
      ),
      transactions: _list(
        body['transaction_logs'],
      ).map(CheckpointTransaction.fromJson).toList(growable: false),
    );
  }

  static Future<String> _reservationAction(
    String action, {
    required Map<String, dynamic> body,
  }) async {
    final response = await ApiClient.patchJson(
      'owner/reservations/$action',
      headers: await _headers(),
      body: body,
    );
    ApiClient.requireStatus(response, const {200});
    return ApiClient.decodeObject(response)['message']?.toString() ??
        'Reservation updated.';
  }

  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.requireToken();
    return AuthService.bearerHeaders(token);
  }

  static List<Map<String, dynamic>> _list(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }
}
