import '../models/conversation_message.dart';
import '../models/reservation_call.dart';
import '../models/reservation_conversation.dart';
import 'api_client.dart';
import 'auth_service.dart';

class CallSignalBatch {
  const CallSignalBatch({required this.call, required this.signals});

  final ReservationCall call;
  final List<Map<String, dynamic>> signals;
}

class ConversationService {
  static Future<Map<String, String>> _headers() async {
    return AuthService.bearerHeaders(await AuthService.requireToken());
  }

  static Future<ReservationConversation> fetch(
    int reservationId, {
    int afterId = 0,
  }) async {
    final response = await ApiClient.get(
      'reservations/$reservationId/conversation?after_id=$afterId',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    return ReservationConversation.fromJson(ApiClient.decodeObject(response));
  }

  static Future<ConversationMessage> sendMessage(
    int reservationId,
    String body,
  ) async {
    final response = await ApiClient.postJson(
      'reservations/$reservationId/conversation/messages',
      headers: await _headers(),
      body: {'body': body},
    );
    ApiClient.requireStatus(response, const {201});
    final message = ApiClient.decodeObject(response)['message'];
    return ConversationMessage.fromJson(Map<String, dynamic>.from(message));
  }

  static Future<void> markRead(int reservationId) async {
    final response = await ApiClient.patchJson(
      'reservations/$reservationId/conversation/read',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
  }

  static Future<ReservationCall?> activeCall(int reservationId) async {
    final response = await ApiClient.get(
      'reservations/$reservationId/conversation/calls/active',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    final call = ApiClient.decodeObject(response)['call'];
    if (call is! Map) return null;
    return ReservationCall.fromJson(Map<String, dynamic>.from(call));
  }

  static Future<ReservationCall> createCall(int reservationId) async {
    final response = await ApiClient.post(
      'reservations/$reservationId/conversation/calls',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {201});
    return _callFrom(response);
  }

  static Future<ReservationCall> acceptCall(ReservationCall call) {
    return _changeCall(call, 'accept');
  }

  static Future<ReservationCall> rejectCall(ReservationCall call) {
    return _changeCall(call, 'reject');
  }

  static Future<ReservationCall> endCall(ReservationCall call) {
    return _changeCall(call, 'end');
  }

  static Future<CallSignalBatch> signals(
    ReservationCall call, {
    int afterId = 0,
  }) async {
    final response = await ApiClient.get(
      'reservations/${call.reservationId}/conversation/calls/${call.id}/signals?after_id=$afterId',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    final body = ApiClient.decodeObject(response);
    final currentCall = ReservationCall.fromJson(
      Map<String, dynamic>.from(body['call'] as Map),
    );
    final signals = (body['signals'] as List? ?? const [])
        .whereType<Map>()
        .map((signal) => Map<String, dynamic>.from(signal))
        .toList();
    return CallSignalBatch(call: currentCall, signals: signals);
  }

  static Future<void> sendSignal(
    ReservationCall call,
    String type,
    Map<String, dynamic> payload,
  ) async {
    final response = await ApiClient.postJson(
      'reservations/${call.reservationId}/conversation/calls/${call.id}/signals',
      headers: await _headers(),
      body: {'type': type, 'payload': payload},
    );
    ApiClient.requireStatus(response, const {201});
  }

  static Future<ReservationCall> _changeCall(
    ReservationCall call,
    String action,
  ) async {
    final response = await ApiClient.patchJson(
      'reservations/${call.reservationId}/conversation/calls/${call.id}/$action',
      headers: await _headers(),
    );
    ApiClient.requireStatus(response, const {200});
    return _callFrom(response);
  }

  static ReservationCall _callFrom(dynamic response) {
    final call = ApiClient.decodeObject(response)['call'];
    return ReservationCall.fromJson(Map<String, dynamic>.from(call));
  }
}
