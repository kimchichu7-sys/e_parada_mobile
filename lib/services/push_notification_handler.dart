import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'auth_service.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  developer.log(
    'FCM Background message: ${message.messageId}',
    name: 'PushNotificationHandler',
  );
}

class PushNotificationHandler {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;

      // Request notification permissions for iOS and Android 13+
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      developer.log(
        'User granted notification permission: ${settings.authorizationStatus}',
        name: 'PushNotificationHandler',
      );

      // Set presentation options for foreground alerts
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Listen for token updates
      messaging.onTokenRefresh.listen((newToken) {
        _syncTokenWithBackend(newToken);
      });

      // Obtain current token and sync
      final token = await messaging.getToken();
      if (token != null) {
        developer.log('FCM Device Token: $token', name: 'PushNotificationHandler');
        await _syncTokenWithBackend(token);
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log(
          'Foreground message received: ${message.notification?.title}',
          name: 'PushNotificationHandler',
        );
      });

      // Handle message tapped when app was in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        developer.log(
          'App opened via notification: ${message.data}',
          name: 'PushNotificationHandler',
        );
      });

      _isInitialized = true;
    } catch (e, stack) {
      developer.log(
        'PushNotificationHandler initialization notice: $e (Ensure google-services.json is in android/app/)',
        name: 'PushNotificationHandler',
        error: e,
        stackTrace: stack,
      );
    }
  }

  static Future<void> syncCurrentToken() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await _syncTokenWithBackend(token);
        }
      }
    } catch (_) {}
  }

  static Future<void> _syncTokenWithBackend(String token) async {
    try {
      final authToken = await AuthService.authToken();
      if (authToken != null && authToken.isNotEmpty) {
        await NotificationService.registerDeviceToken(
          token,
          platform: 'android',
        );
      }
    } catch (e) {
      developer.log(
        'Could not register token with backend: $e',
        name: 'PushNotificationHandler',
      );
    }
  }
}
