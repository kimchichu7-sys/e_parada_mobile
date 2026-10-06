import 'dart:convert';

class ConversationCallLog {
  const ConversationCallLog({
    required this.callId,
    required this.title,
    required this.durationText,
    required this.durationSeconds,
    required this.status,
    required this.callerId,
    required this.calleeId,
  });

  final int callId;
  final String title;
  final String durationText;
  final int durationSeconds;
  final String status;
  final int callerId;
  final int calleeId;

  static ConversationCallLog? tryParse(String body) {
    final trimmed = body.trim();
    if (!trimmed.startsWith('{"type":"call_log"') &&
        !trimmed.startsWith('{"type": "call_log"')) {
      return null;
    }
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is! Map<String, dynamic> || decoded['type'] != 'call_log') {
        return null;
      }
      return ConversationCallLog(
        callId: (decoded['call_id'] as num?)?.toInt() ?? 0,
        title: decoded['title']?.toString() ?? 'Audio call',
        durationText: decoded['duration_text']?.toString() ?? 'Call ended',
        durationSeconds: (decoded['duration_seconds'] as num?)?.toInt() ?? 0,
        status: decoded['status']?.toString() ?? 'ended',
        callerId: (decoded['caller_id'] as num?)?.toInt() ?? 0,
        calleeId: (decoded['callee_id'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      return null;
    }
  }
}

class ConversationMessage {
  const ConversationMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.body,
    required this.createdAt,
  });

  final int id;
  final int senderId;
  final String senderName;
  final String body;
  final DateTime? createdAt;

  ConversationCallLog? get callLog => ConversationCallLog.tryParse(body);
  bool get isCallLog => callLog != null;

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      id: (json['id'] as num).toInt(),
      senderId: (json['sender_id'] as num).toInt(),
      senderName: json['sender_name']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
