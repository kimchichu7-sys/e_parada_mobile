import 'package:flutter/foundation.dart';

const insecureCallMessage =
    'Audio calls require a secure HTTPS connection on phones. '
    'Open E-Parada using an HTTPS address, then try again.';

const microphonePermissionMessage =
    'Microphone access is blocked. Allow microphone access for E-Parada '
    'in your settings, then try again.';

String? callPreflightMessage({required bool isWeb, required Uri pageUri}) {
  if (!isWeb || pageUri.scheme == 'https' || _isLoopback(pageUri.host)) {
    return null;
  }

  return insecureCallMessage;
}

String callSetupErrorMessage(Object error) {
  final details = error.toString().toLowerCase();

  if (details.contains('notallowederror') ||
      details.contains('permission denied') ||
      details.contains('permissiondismissed') ||
      details.contains('permission denied by system') ||
      details.contains('mediastreamtrack initialization failed') ||
      details.contains('getusermediafailed') ||
      details.contains('failed to create new track') ||
      details.contains('securityexception') ||
      details.contains('bluetooth_connect')) {
    return microphonePermissionMessage;
  }

  if (details.contains('notfounderror') ||
      details.contains('requested device not found')) {
    return 'No microphone was found. Connect or enable a microphone, then try again.';
  }

  if (details.contains('notreadableerror') ||
      details.contains('track starter failure')) {
    return 'The microphone is being used by another app. Close the other app, then try again.';
  }

  debugPrint('Audio call setup failed: $error');
  return 'Unable to start the audio call. Check your connection, then try again.';
}

bool _isLoopback(String host) {
  return host == 'localhost' || host == '127.0.0.1' || host == '::1';
}
