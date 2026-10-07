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
      details.contains('record_audio') ||
      details.contains('mediastreamtrack initialization failed') ||
      details.contains('getusermediafailed') ||
      details.contains('failed to create new track') ||
      details.contains('securityexception') ||
      details.contains('bluetooth_connect') ||
      details.contains('permission')) {
    return microphonePermissionMessage;
  }

  if (details.contains('notfounderror') ||
      details.contains('requested device not found') ||
      details.contains('no microphone') ||
      details.contains('audiorecord-initialization-failed')) {
    return 'No microphone was found. Connect or enable a microphone, then try again.';
  }

  if (details.contains('notreadableerror') ||
      details.contains('track starter failure') ||
      details.contains('in use') ||
      details.contains('busy')) {
    return 'The microphone is being used by another app. Close the other app, then try again.';
  }

  if (details.contains('call has ended') ||
      details.contains('call ended') ||
      details.contains('rejected') ||
      details.contains('declined')) {
    return 'The call was ended or declined by the other party.';
  }

  if (details.contains('clientexception') ||
      details.contains('socketexception') ||
      details.contains('timeoutexception') ||
      details.contains('connection refused') ||
      details.contains('network is unreachable') ||
      details.contains('failed host lookup') ||
      details.contains('cannot reach the e-parada server')) {
    return 'Unable to reach the server. Check your network connection and try again.';
  }

  debugPrint('Audio call setup failed: $error');
  final clean = error.toString().replaceAll(RegExp(r'^Exception:\s*'), '').trim();
  if (clean.isNotEmpty && clean.length <= 80 && !clean.contains('\n')) {
    return 'Call setup failed: $clean';
  }
  return 'Unable to start the audio call. Please check your connection and try again.';
}

bool _isLoopback(String host) {
  return host == 'localhost' || host == '127.0.0.1' || host == '::1';
}
