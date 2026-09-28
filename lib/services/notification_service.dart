import '../models/mobile_notification.dart';
import 'api_client.dart';
import 'auth_service.dart';

class NotificationService {
  static Future<NotificationInboxResult> fetchInbox({
    String type = 'all',
    int page = 1,
  }) async {
    final query = Uri(queryParameters: {'type': type, 'page': '$page'}).query;
    final response = await ApiClient.get(
      'notifications?$query',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    return NotificationInboxResult.fromJson(ApiClient.decodeObject(response));
  }

  static Future<String> markAsRead(int notificationId) async {
    final response = await ApiClient.patchJson(
      'notifications/$notificationId/read',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    return _message(response, 'Notification marked as read.');
  }

  static Future<String> markAllAsRead() async {
    final response = await ApiClient.patchJson(
      'notifications/read-all',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    return _message(response, 'Notifications marked as read.');
  }

  static Future<String> deleteNotification(int notificationId) async {
    final response = await ApiClient.delete(
      'notifications/$notificationId',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    return _message(response, 'Notification deleted.');
  }

  static Future<String> clearRead() async {
    final response = await ApiClient.delete(
      'notifications/clear-read',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    return _message(response, 'Read notifications cleared.');
  }

  static Future<String> clearAll() async {
    final response = await ApiClient.delete(
      'notifications/clear-all',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    return _message(response, 'Notifications cleared.');
  }

  static Future<String> registerDeviceToken(
    String token, {
    String platform = 'android',
    String? deviceName,
  }) async {
    final response = await ApiClient.postJson(
      'device-token',
      headers: await _headers(),
      body: {
        'token': token,
        'platform': platform,
        if (deviceName != null) 'device_name': deviceName,
      },
    );
    ApiClient.requireStatus(response, const {200});
    return _message(response, 'Device token registered successfully.');
  }

  static Future<String> deleteDeviceToken(String token) async {
    final response = await ApiClient.deleteJson(
      'device-token',
      headers: await _headers(),
      body: {'token': token},
    );
    ApiClient.requireStatus(response, const {200});
    return _message(response, 'Device token deleted.');
  }

  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.requireToken();
    return AuthService.bearerHeaders(token);
  }

  static String _message(dynamic response, String fallback) {
    return ApiClient.decodeObject(response)['message']?.toString() ?? fallback;
  }
}
