import '../models/driver_reservation.dart';
import '../models/reservation_availability.dart';
import 'api_client.dart';
import 'auth_service.dart';

class ReservationService {
  static Future<List<DriverReservation>> fetchReservations() async {
    final response = await ApiClient.get(
      'driver/reservations',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    final values = ApiClient.decodeObject(response)['reservations'];
    if (values is! List) {
      throw const ApiException('The reservation list is incomplete.');
    }

    return values
        .whereType<Map>()
        .map(
          (value) =>
              DriverReservation.fromJson(Map<String, dynamic>.from(value)),
        )
        .toList(growable: false);
  }

  static Future<ReservationAvailability> checkAvailability({
    required int parkingSpaceId,
    required int vehicleId,
    required String reservationDate,
    required String endDate,
    required String startTime,
    required String endTime,
  }) async {
    final query = Uri(
      queryParameters: {
        'vehicle_id': '$vehicleId',
        'reservation_date': reservationDate,
        'end_date': endDate,
        'start_time': startTime,
        'end_time': endTime,
      },
    ).query;
    final response = await ApiClient.get(
      'driver/parking-spaces/$parkingSpaceId/availability?$query',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    return ReservationAvailability.fromJson(ApiClient.decodeObject(response));
  }

  static Future<String> createReservation({
    required int parkingSpaceId,
    required int vehicleId,
    required String vehicleType,
    required int parkingSlotId,
    required String reservationDate,
    required String endDate,
    required String startTime,
    required String endTime,
  }) async {
    final response = await ApiClient.postJson(
      'driver/parking-spaces/$parkingSpaceId/reservations',
      headers: await _headers(),
      body: {
        'vehicle_id': vehicleId,
        'vehicle_type': vehicleType,
        'parking_slot_id': parkingSlotId,
        'reservation_date': reservationDate,
        'end_date': endDate,
        'start_time': startTime,
        'end_time': endTime,
      },
    );
    ApiClient.requireStatus(response, const {201});
    return _message(response, 'Reservation submitted.');
  }

  static Future<String> cancel(int reservationId, {String? reason}) async {
    final response = await ApiClient.patchJson(
      'driver/reservations/$reservationId/cancel',
      headers: await _headers(),
      body: {'cancellation_reason': reason ?? ''},
    );
    ApiClient.requireStatus(response, const {200});
    return _message(response, 'Reservation cancelled.');
  }

  static Future<String> reschedule({
    required int reservationId,
    required int vehicleId,
    required String reservationDate,
    required String endDate,
    required String startTime,
    required String endTime,
    String? reason,
  }) async {
    final response = await ApiClient.patchJson(
      'driver/reservations/$reservationId/reschedule',
      headers: await _headers(),
      body: {
        'vehicle_id': vehicleId,
        'reservation_date': reservationDate,
        'end_date': endDate,
        'start_time': startTime,
        'end_time': endTime,
        'reschedule_reason': reason ?? '',
      },
    );
    ApiClient.requireStatus(response, const {200});
    return _message(response, 'Reservation rescheduled.');
  }

  static Future<String> requestExtension({
    required int reservationId,
    required String endDate,
    required String endTime,
    String? reason,
  }) async {
    final response = await ApiClient.patchJson(
      'driver/reservations/$reservationId/extension',
      headers: await _headers(),
      body: {
        'extension_end_date': endDate,
        'extension_end_time': endTime,
        'extension_reason': reason ?? '',
      },
    );
    ApiClient.requireStatus(response, const {200});
    return _message(response, 'Extension requested.');
  }

  static Future<String> submitPayment({
    required int reservationId,
    required String paymentMethod,
    String? referenceNumber,
    UploadFileData? paymentProof,
  }) async {
    final fields = {'payment_method': paymentMethod};
    if (referenceNumber != null && referenceNumber.isNotEmpty) {
      fields['reference_number'] = referenceNumber;
    }
    final response = await ApiClient.postMultipart(
      'driver/reservations/$reservationId/payment',
      headers: await _headers(),
      fields: fields,
      files: paymentProof == null ? null : {'payment_proof': paymentProof},
    );
    ApiClient.requireStatus(response, const {200});
    return _message(response, 'Payment submitted.');
  }

  static Future<String> submitFeedback({
    required int reservationId,
    required int rating,
    required String comment,
  }) async {
    final response = await ApiClient.postJson(
      'driver/reservations/$reservationId/feedback',
      headers: await _headers(),
      body: {'rating': rating, 'comment': comment},
    );
    ApiClient.requireStatus(response, const {201});
    return _message(response, 'Feedback submitted.');
  }

  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.requireToken();
    return AuthService.bearerHeaders(token);
  }

  static String _message(dynamic response, String fallback) {
    return ApiClient.decodeObject(response)['message']?.toString() ?? fallback;
  }
}
