import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/mobile_notification.dart';
import 'api_client.dart';
import 'auth_service.dart';

class NotificationService {
  static final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);
  static Future<void>? _refreshInFlight;

  static void syncUnreadCount(int count) {
    final normalized = count < 0 ? 0 : count;
    if (unreadCountNotifier.value != normalized) {
      unreadCountNotifier.value = normalized;
    }
  }

  static void decrementUnreadCount([int by = 1]) {
    if (by <= 0) return;
    syncUnreadCount(unreadCountNotifier.value - by);
  }

  static Future<void> refreshUnreadCount({bool silent = true}) {
    final inFlight = _refreshInFlight;
    if (inFlight != null) return inFlight;

    late final Future<void> future;
    future = _performUnreadRefresh(silent: silent).whenComplete(() {
      if (identical(_refreshInFlight, future)) {
        _refreshInFlight = null;
      }
    });
    _refreshInFlight = future;
    return future;
  }

  static Future<void> _performUnreadRefresh({required bool silent}) async {
    try {
      final token = await AuthService.authToken();
      if (token == null || token.isEmpty) {
        syncUnreadCount(0);
        return;
      }
      await fetchInbox();
    } catch (_) {
      if (!silent) rethrow;
    }
  }

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
    final body = ApiClient.decodeObject(response);
    final result = NotificationInboxResult.fromJson(body);
    syncUnreadCount(result.unreadCount);
    return result;
  }

  static Future<String> markAsRead(int notificationId) async {
    final response = await ApiClient.patchJson(
      'notifications/$notificationId/read',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    final body = ApiClient.decodeObject(response);
    _syncUnreadFromBody(body);
    return body['message']?.toString() ?? 'Notification marked as read.';
  }

  static Future<String> markAllAsRead() async {
    final response = await ApiClient.patchJson(
      'notifications/read-all',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    final body = ApiClient.decodeObject(response);
    _syncUnreadFromBody(body, fallbackCount: 0);
    return body['message']?.toString() ?? 'Notifications marked as read.';
  }

  static Future<String> deleteNotification(int notificationId) async {
    final response = await ApiClient.delete(
      'notifications/$notificationId',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    final body = ApiClient.decodeObject(response);
    _syncUnreadFromBody(body);
    return body['message']?.toString() ?? 'Notification deleted.';
  }

  static Future<String> clearRead() async {
    final response = await ApiClient.delete(
      'notifications/clear-read',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    final body = ApiClient.decodeObject(response);
    _syncUnreadFromBody(body);
    return body['message']?.toString() ?? 'Read notifications cleared.';
  }

  static Future<String> clearAll() async {
    final response = await ApiClient.delete(
      'notifications/clear-all',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    final body = ApiClient.decodeObject(response);
    _syncUnreadFromBody(body, fallbackCount: 0);
    return body['message']?.toString() ?? 'Notifications cleared.';
  }

  static Future<Map<String, dynamic>?> resolveConversation(int notificationId) async {
    try {
      final response = await ApiClient.get(
        'notifications/$notificationId/resolve-conversation',
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        return ApiClient.decodeObject(response);
      }
    } catch (_) {}
    return null;
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
        'device_name': ?deviceName,
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

  static void _syncUnreadFromBody(
    Map<String, dynamic> body, {
    int? fallbackCount,
  }) {
    final raw = body['unread_count'];
    if (raw is int) {
      syncUnreadCount(raw);
    } else if (raw != null) {
      final parsed = int.tryParse(raw.toString());
      if (parsed != null) {
        syncUnreadCount(parsed);
      } else if (fallbackCount != null) {
        syncUnreadCount(fallbackCount);
      }
    } else if (fallbackCount != null) {
      syncUnreadCount(fallbackCount);
    }
  }

  static String _message(dynamic response, String fallback) {
    return ApiClient.decodeObject(response)['message']?.toString() ?? fallback;
  }
}
