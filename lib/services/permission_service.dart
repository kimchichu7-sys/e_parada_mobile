import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MicrophonePermissionHelper {
  static const _channel = MethodChannel('ph.eparada.mobile/permissions');

  static Future<bool> hasPermission() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }
    try {
      final granted =
          await _channel.invokeMethod<bool>('checkMicrophonePermission');
      return granted ?? false;
    } on Object catch (e) {
      debugPrint('Check microphone permission error: $e');
      return false;
    }
  }

  static Future<bool> requestPermission() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }
    try {
      final granted =
          await _channel.invokeMethod<bool>('requestMicrophonePermission');
      return granted ?? false;
    } on Object catch (e) {
      debugPrint('Request microphone permission error: $e');
      return false;
    }
  }

  static Future<void> openAppSettings() async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod<void>('openAppSettings');
    } on Object catch (e) {
      debugPrint('Open app settings error: $e');
    }
  }
}
