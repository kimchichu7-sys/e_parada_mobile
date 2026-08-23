import 'dart:typed_data';

import '../models/admin_models.dart';
import 'api_client.dart';
import 'auth_service.dart';

class AdminOperationsService {
  static Future<List<AdminUserReview>> fetchUsers({String? status}) async {
    final response = await ApiClient.get(
      'admin/users${_query(status)}',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    return _list(
      ApiClient.decodeObject(response)['users'],
    ).map(AdminUserReview.fromJson).toList(growable: false);
  }

  static Future<String> approveUser(int id) => _action(
    'admin/users/$id/approve',
    const {},
    fallback: 'Account approved.',
  );

  static Future<String> rejectUser(int id, String notes) => _action(
    'admin/users/$id/reject',
    {'verification_notes': notes},
    fallback: 'Account rejected.',
  );

  static Future<Uint8List> identityDocument(int id) {
    return _privateImage('admin/users/$id/identity-document');
  }

  static Future<Uint8List> identityDocumentBack(int id) {
    return _privateImage('admin/users/$id/identity-document/back');
  }

  static Future<List<AdminVehicleReview>> fetchVehicles({
    String? status,
  }) async {
    final response = await ApiClient.get(
      'admin/vehicles${_query(status)}',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    return _list(
      ApiClient.decodeObject(response)['vehicles'],
    ).map(AdminVehicleReview.fromJson).toList(growable: false);
  }

  static Future<String> approveVehicle(int id) => _action(
    'admin/vehicles/$id/approve',
    const {},
    fallback: 'Vehicle approved.',
  );

  static Future<String> rejectVehicle(int id, String notes) => _action(
    'admin/vehicles/$id/reject',
    {'verification_notes': notes},
    fallback: 'Vehicle rejected.',
  );

  static Future<Uint8List> vehiclePhoto(int id) {
    return _privateImage('admin/vehicles/$id/photo');
  }

  static Future<Uint8List> vehiclePhotoBack(int id) {
    return _privateImage('admin/vehicles/$id/photo/back');
  }

  static Future<List<AdminParkingSpaceReview>> fetchSpaces({
    String? status,
  }) async {
    final response = await ApiClient.get(
      'admin/parking-spaces${_query(status)}',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    return _list(
      ApiClient.decodeObject(response)['parking_spaces'],
    ).map(AdminParkingSpaceReview.fromJson).toList(growable: false);
  }

  static Future<String> reviewSpace(
    int id, {
    required String status,
    required String notes,
    Map<String, double>? rates,
  }) => _action('admin/parking-spaces/$id/review', {
    'approval_status': status,
    'admin_notes': notes,
    'vehicle_hourly_rates': ?rates,
  }, fallback: 'Parking space review saved.');

  static Future<List<AdminReservationReview>> fetchReservations({
    String? disputeStatus,
  }) async {
    final response = await ApiClient.get(
      'admin/reservations${_query(disputeStatus, key: 'dispute_status')}',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    return _list(
      ApiClient.decodeObject(response)['reservations'],
    ).map(AdminReservationReview.fromJson).toList(growable: false);
  }

  static Future<String> updateReservation(
    int id, {
    required String disputeStatus,
    required String disputeNotes,
    required String internalNotes,
  }) => _action('admin/reservations/$id', {
    'dispute_status': disputeStatus,
    'dispute_notes': disputeNotes,
    'admin_internal_notes': internalNotes,
  }, fallback: 'Reservation review saved.');

  static Future<List<AdminSupportRequest>> fetchSupport({
    String? status,
  }) async {
    final response = await ApiClient.get(
      'admin/support-requests${_query(status)}',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    return _list(
      ApiClient.decodeObject(response)['support_requests'],
    ).map(AdminSupportRequest.fromJson).toList(growable: false);
  }

  static Future<String> updateSupport(int id, String status) => _action(
    'admin/support-requests/$id',
    {'status': status},
    fallback: 'Support request updated.',
  );

  static Future<AdminActivityData> fetchActivity() async {
    final response = await ApiClient.get(
      'admin/activity',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    final body = ApiClient.decodeObject(response);
    return AdminActivityData(
      auditLogs: _list(
        body['audit_logs'],
      ).map(AdminAuditLog.fromJson).toList(growable: false),
      qrLogs: _list(
        body['qr_transaction_logs'],
      ).map(AdminQrLog.fromJson).toList(growable: false),
    );
  }

  static Future<String> _action(
    String path,
    Map<String, dynamic> body, {
    required String fallback,
  }) async {
    final response = await ApiClient.patchJson(
      path,
      headers: await _headers(),
      body: body,
    );
    ApiClient.requireStatus(response, const {200});
    return ApiClient.decodeObject(response)['message']?.toString() ?? fallback;
  }

  static Future<Uint8List> _privateImage(String path) async {
    final response = await ApiClient.get(path, headers: await _headers());
    ApiClient.requireStatus(response, const {200});
    return response.bodyBytes;
  }

  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.requireToken();
    return AuthService.bearerHeaders(token);
  }

  static String _query(String? value, {String key = 'status'}) {
    if (value == null || value.isEmpty) return '';
    return '?$key=${Uri.encodeQueryComponent(value)}';
  }

  static List<Map<String, dynamic>> _list(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }
}
