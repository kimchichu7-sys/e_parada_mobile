import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../models/reservation_call.dart';
import '../services/api_client.dart';
import '../services/call_environment.dart';
import '../services/conversation_service.dart';

class AudioCallScreen extends StatefulWidget {
  const AudioCallScreen({
    super.key,
    required this.call,
    required this.otherPartyName,
  });

  final ReservationCall call;
  final String otherPartyName;

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  Timer? _pollTimer;
  late ReservationCall _call;
  final List<RTCIceCandidate> _pendingCandidates = [];
  int _lastSignalId = 0;
  bool _remoteDescriptionSet = false;
  bool _muted = false;
  bool _busy = true;
  bool _polling = false;
  bool _setupFailed = false;
  String _status = 'Connecting...';

  @override
  void initState() {
    super.initState();
    _call = widget.call;
    unawaited(_start());
  }

  Future<void> _start() async {
    final preflightMessage = callPreflightMessage(
      isWeb: kIsWeb,
      pageUri: Uri.base,
    );
    if (preflightMessage != null) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _setupFailed = true;
        _status = preflightMessage;
      });
      return;
    }

    try {
      await _releaseMedia();
      if (mounted) {
        setState(() {
          _busy = true;
          _setupFailed = false;
          _status = 'Connecting...';
        });
      }

      if (_call.isIncoming && _call.status == 'ringing') {
        _call = await ConversationService.acceptCall(_call);
      }

      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': false,
      });
      _peerConnection = await createPeerConnection({
        'iceServers': [
          {
            'urls': ['stun:stun.l.google.com:19302'],
          },
        ],
      });

      for (final track in _localStream!.getAudioTracks()) {
        await _peerConnection!.addTrack(track, _localStream!);
      }

      _peerConnection!.onIceCandidate = (candidate) {
        if (candidate.candidate == null) return;
        unawaited(
          ConversationService.sendSignal(_call, 'ice', {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          }),
        );
      };
      _peerConnection!.onConnectionState = (state) {
        if (!mounted) return;
        setState(() {
          _status = switch (state) {
            RTCPeerConnectionState.RTCPeerConnectionStateConnected =>
              'Connected',
            RTCPeerConnectionState.RTCPeerConnectionStateFailed =>
              'Connection failed',
            RTCPeerConnectionState.RTCPeerConnectionStateDisconnected =>
              'Disconnected',
            _ => _call.status == 'ringing' ? 'Ringing...' : 'Connecting...',
          };
        });
      };

      if (!_call.isIncoming) {
        final offer = await _peerConnection!.createOffer();
        await _peerConnection!.setLocalDescription(offer);
        await ConversationService.sendSignal(_call, 'offer', {
          'sdp': offer.sdp,
          'type': offer.type,
        });
      }

      if (mounted) {
        setState(() {
          _busy = false;
          _setupFailed = false;
          _status = _call.status == 'ringing' ? 'Ringing...' : 'Connecting...';
        });
      }
      await _pollSignals();
      _pollTimer = Timer.periodic(
        const Duration(milliseconds: 900),
        (_) => unawaited(_pollSignals()),
      );
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _setupFailed = true;
        _status = error is ApiException
            ? error.message
            : callSetupErrorMessage(error);
      });
    }
  }

  Future<void> _retrySetup() async {
    if (_busy) return;
    await _start();
  }

  Future<void> _releaseMedia() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    for (final track in _localStream?.getTracks() ?? <MediaStreamTrack>[]) {
      track.stop();
    }
    await _localStream?.dispose();
    await _peerConnection?.close();
    _localStream = null;
    _peerConnection = null;
    _remoteDescriptionSet = false;
    _pendingCandidates.clear();
  }

  Future<void> _pollSignals() async {
    if (_polling || !_call.isActive) return;
    _polling = true;
    try {
      final batch = await ConversationService.signals(
        _call,
        afterId: _lastSignalId,
      );
      _call = batch.call;

      for (final signal in batch.signals) {
        final id = (signal['id'] as num).toInt();
        if (id > _lastSignalId) _lastSignalId = id;
        final senderId = (signal['sender_id'] as num).toInt();
        if (senderId == (_call.isIncoming ? _call.calleeId : _call.callerId)) {
          continue;
        }
        final type = signal['type']?.toString();
        final payload = Map<String, dynamic>.from(signal['payload'] as Map);

        if (type == 'offer') {
          await _setRemoteDescription(payload);
          final answer = await _peerConnection!.createAnswer();
          await _peerConnection!.setLocalDescription(answer);
          await ConversationService.sendSignal(_call, 'answer', {
            'sdp': answer.sdp,
            'type': answer.type,
          });
        } else if (type == 'answer') {
          await _setRemoteDescription(payload);
        } else if (type == 'ice') {
          final candidate = RTCIceCandidate(
            payload['candidate']?.toString(),
            payload['sdpMid']?.toString(),
            (payload['sdpMLineIndex'] as num?)?.toInt(),
          );
          if (_remoteDescriptionSet) {
            await _peerConnection?.addCandidate(candidate);
          } else {
            _pendingCandidates.add(candidate);
          }
        }
      }

      if (!_call.isActive && mounted) {
        _pollTimer?.cancel();
        setState(() => _status = 'Call ended');
        await Future<void>.delayed(const Duration(milliseconds: 700));
        if (mounted) Navigator.of(context).pop();
      }
    } catch (_) {
      // A later poll retries brief network interruptions.
    } finally {
      _polling = false;
    }
  }

  Future<void> _setRemoteDescription(Map<String, dynamic> payload) async {
    if (_remoteDescriptionSet) return;
    await _peerConnection?.setRemoteDescription(
      RTCSessionDescription(
        payload['sdp']?.toString(),
        payload['type']?.toString(),
      ),
    );
    _remoteDescriptionSet = true;
    for (final candidate in _pendingCandidates) {
      await _peerConnection?.addCandidate(candidate);
    }
    _pendingCandidates.clear();
  }

  void _toggleMute() {
    _muted = !_muted;
    for (final track
        in _localStream?.getAudioTracks() ?? <MediaStreamTrack>[]) {
      track.enabled = !_muted;
    }
    setState(() {});
  }

  Future<void> _hangUp() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ConversationService.endCall(_call);
    } finally {
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    for (final track in _localStream?.getTracks() ?? <MediaStreamTrack>[]) {
      track.stop();
    }
    unawaited(_localStream?.dispose());
    unawaited(_peerConnection?.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final initials = widget.otherPartyName.trim().isEmpty
        ? 'E'
        : widget.otherPartyName.trim()[0].toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text('E-Parada call')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 54,
                  backgroundColor: colors.primaryContainer,
                  child: Text(
                    initials,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.otherPartyName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: _setupFailed ? colors.error : null,
                    ),
                  ),
                ),
                if (_setupFailed) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _retrySetup,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try again'),
                  ),
                ],
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      onPressed: _busy ? null : _toggleMute,
                      tooltip: _muted ? 'Unmute' : 'Mute',
                      icon: Icon(_muted ? Icons.mic_off : Icons.mic),
                    ),
                    const SizedBox(width: 28),
                    IconButton.filled(
                      onPressed: _busy ? null : _hangUp,
                      tooltip: 'End call',
                      style: IconButton.styleFrom(
                        backgroundColor: colors.error,
                        foregroundColor: colors.onError,
                      ),
                      icon: const Icon(Icons.call_end),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
