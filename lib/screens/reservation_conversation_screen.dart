import 'dart:async';

import 'package:flutter/material.dart';

import '../models/conversation_message.dart';
import '../models/reservation_call.dart';
import '../models/reservation_conversation.dart';
import '../services/api_client.dart';
import '../services/conversation_service.dart';
import 'audio_call_screen.dart';

class ReservationConversationScreen extends StatefulWidget {
  const ReservationConversationScreen({
    super.key,
    required this.reservationId,
    required this.otherPartyName,
  });

  final int reservationId;
  final String otherPartyName;

  @override
  State<ReservationConversationScreen> createState() =>
      _ReservationConversationScreenState();
}

class _ReservationConversationScreenState
    extends State<ReservationConversationScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ConversationMessage> _messages = [];
  Timer? _refreshTimer;
  ReservationConversation? _conversation;
  int? _shownIncomingCallId;
  bool _loading = true;
  bool _sending = false;
  bool _refreshing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_refresh(initial: true));
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(milliseconds: 1500),
      (_) => unawaited(_refresh()),
    );
  }

  Future<void> _openCall(ReservationCall call) async {
    _refreshTimer?.cancel();
    try {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AudioCallScreen(
            call: call,
            otherPartyName:
                _conversation?.otherPartyName ?? widget.otherPartyName,
          ),
        ),
      );
    } finally {
      if (mounted) {
        _startRefreshTimer();
        unawaited(_refresh());
      }
    }
  }

  Future<void> _refresh({bool initial = false}) async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      final validMessages = _messages.where((m) => m.id > 0).toList();
      final afterId = validMessages.isEmpty ? 0 : validMessages.last.id;
      final conversation = await ConversationService.fetch(
        widget.reservationId,
        afterId: afterId,
      );
      if (!mounted) return;

      setState(() {
        _conversation = conversation;
        for (final message in conversation.messages) {
          if (_messages.every((existing) => existing.id != message.id)) {
            _messages.add(message);
          }
        }
        _messages.sort((a, b) => a.id.compareTo(b.id));
        _loading = false;
        _error = null;
      });

      if (conversation.messages.isNotEmpty || initial) {
        unawaited(ConversationService.markRead(widget.reservationId));
        _scrollToBottom();
      }

      final activeCall = conversation.activeCall;
      if (activeCall?.isIncoming == true &&
          activeCall!.status == 'ringing' &&
          _shownIncomingCallId != activeCall.id &&
          mounted) {
        _shownIncomingCallId = activeCall.id;
        unawaited(_showIncomingCall(activeCall));
      }
    } on ApiException catch (error) {
      if (mounted && initial) {
        setState(() {
          _loading = false;
          _error = error.message;
        });
      }
    } finally {
      _refreshing = false;
    }
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;

    final tempId = -DateTime.now().millisecondsSinceEpoch;
    final otherPartyId = _conversation?.otherPartyId ?? 0;
    final mySenderId = otherPartyId == 0 ? -1 : (otherPartyId + 1);
    final optimisticMessage = ConversationMessage(
      id: tempId,
      senderId: mySenderId,
      senderName: 'You',
      body: text,
      createdAt: DateTime.now(),
    );

    _messageController.clear();
    setState(() {
      _messages.add(optimisticMessage);
      _sending = true;
    });
    _scrollToBottom();

    try {
      final message = await ConversationService.sendMessage(
        widget.reservationId,
        text,
      );
      if (!mounted) return;
      setState(() {
        final idx = _messages.indexWhere((m) => m.id == tempId);
        if (idx != -1) {
          _messages[idx] = message;
        } else if (_messages.every((m) => m.id != message.id)) {
          _messages.add(message);
        }
        _messages.sort((a, b) => a.id.compareTo(b.id));
      });
      _scrollToBottom();

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) unawaited(_refresh());
      });
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _messages.removeWhere((m) => m.id == tempId);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _startCall() async {
    try {
      final call = await ConversationService.createCall(widget.reservationId);
      if (!mounted) return;
      await _openCall(call);
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  Future<void> _showIncomingCall(ReservationCall call) async {
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.call),
        title: Text('${widget.otherPartyName} is calling'),
        content: const Text('Incoming E-Parada audio call'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Decline'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.call),
            label: const Text('Answer'),
          ),
        ],
      ),
    );

    if (accepted == true && mounted) {
      await _openCall(call);
    } else {
      try {
        await ConversationService.rejectCall(call);
      } catch (_) {
        // The caller may already have ended the call.
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversation = _conversation;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(conversation?.otherPartyName ?? widget.otherPartyName),
            if (conversation != null)
              Text(
                '${conversation.reference} | ${conversation.parkingSpaceName}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Material(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  if (conversation != null && !conversation.canCall) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Audio calling is available for active and confirmed reservations.',
                        ),
                      ),
                    );
                    return;
                  }
                  _startCall();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.phone_in_talk_rounded,
                        color: Colors.white,
                        size: 17,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Call',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBody()),
            _buildComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final conversation = _conversation;
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _refresh(initial: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.forum_outlined, size: 48),
              const SizedBox(height: 12),
              Text(
                'Start your reservation conversation',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Messages stay inside E-Parada and are visible only to this reservation\'s driver and parking provider.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: () {
                  if (conversation != null && !conversation.canCall) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Audio calling is available for active and confirmed reservations.',
                        ),
                      ),
                    );
                    return;
                  }
                  _startCall();
                },
                icon: const Icon(Icons.phone_in_talk_rounded),
                label: Text(
                  'Audio Call ${conversation?.otherPartyName ?? widget.otherPartyName}',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final otherPartyId = _conversation?.otherPartyId;
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final mine = message.senderId != otherPartyId;
        return _MessageBubble(
          message: message,
          mine: mine,
          onCallBack: _conversation?.canCall == true ? _startCall : null,
        );
      },
    );
  }

  static const List<String> _quickReplies = [
    "🚗 I've arrived at the gate",
    "📍 Which bay should I park in?",
    "⏳ Running 10 mins late",
    "🔑 Please share gate / intercom code",
    "🅿️ Vehicle parked safely",
  ];

  Widget _buildComposer() {
    final colors = Theme.of(context).colorScheme;
    return Material(
      elevation: 8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
            child: Row(
              children: _quickReplies.map((reply) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    label: Text(
                      reply,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor:
                        colors.surfaceContainerHighest.withValues(alpha: 0.7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    onPressed: () {
                      _messageController.text = reply;
                      _messageController.selection = TextSelection.fromPosition(
                        TextPosition(offset: reply.length),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 5,
                    maxLength: 2000,
                    decoration: const InputDecoration(
                      hintText: 'Message...',
                      counterText: '',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sending ? null : _send,
                  tooltip: 'Send message',
                  icon: _sending
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.mine,
    this.onCallBack,
  });

  final ConversationMessage message;
  final bool mine;
  final VoidCallback? onCallBack;

  @override
  Widget build(BuildContext context) {
    if (message.isCallLog) {
      return _CallLogBubble(
        message: message,
        callLog: message.callLog!,
        mine: mine,
        onCallBack: onCallBack,
      );
    }

    final colors = Theme.of(context).colorScheme;
    final time = message.createdAt?.toLocal();
    final timeLabel = time == null
        ? ''
        : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        decoration: BoxDecoration(
          color: mine ? colors.primary : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight: mine ? const Radius.circular(4) : null,
            bottomLeft: mine ? null : const Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.body,
              style: TextStyle(
                color: mine ? colors.onPrimary : colors.onSurface,
              ),
            ),
            if (timeLabel.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                timeLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: mine
                      ? colors.onPrimary.withValues(alpha: 0.72)
                      : colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CallLogBubble extends StatelessWidget {
  const _CallLogBubble({
    required this.message,
    required this.callLog,
    required this.mine,
    this.onCallBack,
  });

  final ConversationMessage message;
  final ConversationCallLog callLog;
  final bool mine;
  final VoidCallback? onCallBack;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final time = message.createdAt?.toLocal();
    final timeLabel = time == null
        ? ''
        : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phone_callback_rounded,
                    size: 22,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        callLog.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        callLog.durationText,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: onCallBack,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                backgroundColor: colors.surfaceContainerHighest,
                foregroundColor: colors.onSurface,
              ),
              child: const Text(
                'Call back',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            if (timeLabel.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                timeLabel,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
