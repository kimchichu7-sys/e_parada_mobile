import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class AudioRoutingHelper {
  static const MethodChannel _channel =
      MethodChannel('ph.eparada.mobile/audio_routing');

  static Future<void> setSpeakerphoneOn(bool enable) async {
    if (kIsWeb) return;
    try {
      await Helper.setSpeakerphoneOn(enable);
    } catch (_) {}
    try {
      await _channel.invokeMethod('setSpeakerphoneOn', {'enable': enable});
    } catch (e) {
      debugPrint('Native audio routing error: $e');
    }
  }

  static Future<void> resetAudioRoute() async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod('resetAudioRoute');
    } catch (e) {
      debugPrint('Native audio reset error: $e');
    }
    try {
      await Helper.setSpeakerphoneOn(false);
    } catch (_) {}
  }
}
