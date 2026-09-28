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
  static const _turnUrls = String.fromEnvironment('WEBRTC_TURN_URLS');
  static const _turnUsername = String.fromEnvironment('WEBRTC_TURN_USERNAME');
  static const _turnCredential = String.fromEnvironment(
    'WEBRTC_TURN_CREDENTIAL',
  );

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  Timer? _pollTimer;
  late ReservationCall _call;
  final List<RTCIceCandidate> _pendingCandidates = [];
  RTCSessionDescription? _localAnswer;
  int _lastSignalId = 0;
  bool _remoteDescriptionSet = false;
  bool _rendererInitialized = false;
  bool _connected = false;
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
      if (!_rendererInitialized) {
        await _remoteRenderer.initialize();
        _rendererInitialized = true;
      }
      _peerConnection = await createPeerConnection(_peerConfiguration());

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
      _peerConnection!.onTrack = (event) {
        if (event.track.kind != 'audio' || event.streams.isEmpty) return;
        _remoteRenderer.srcObject = event.streams.first;
      };
      _peerConnection!.onConnectionState = (state) {
        if (!mounted) return;
        setState(() {
          _connected =
              state ==
              RTCPeerConnectionState.RTCPeerConnectionStateConnected;
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
      _peerConnection!.onIceConnectionState = (state) {
        if (!mounted || _connected) return;
        setState(() {
          _status = switch (state) {
            RTCIceConnectionState.RTCIceConnectionStateChecking =>
              'Connecting audio...',
            RTCIceConnectionState.RTCIceConnectionStateConnected ||
            RTCIceConnectionState.RTCIceConnectionStateCompleted =>
              'Connected',
            RTCIceConnectionState.RTCIceConnectionStateFailed =>
              'Direct connection failed. A TURN relay may be required.',
            RTCIceConnectionState.RTCIceConnectionStateDisconnected =>
              'Audio connection interrupted',
            _ => _call.status == 'ringing' ? 'Ringing...' : 'Connecting...',
          };
          if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
              state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
            _connected = true;
          }
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
    _remoteRenderer.srcObject = null;
    _remoteDescriptionSet = false;
    _localAnswer = null;
    _connected = false;
    _lastSignalId = 0;
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

      if (mounted && !_connected && _call.status == 'accepted') {
        setState(() => _status = 'Connecting audio...');
      }

      for (final signal in batch.signals) {
        final id = (signal['id'] as num).toInt();
        if (id <= _lastSignalId) continue;
        final senderId = (signal['sender_id'] as num).toInt();
        if (senderId == (_call.isIncoming ? _call.calleeId : _call.callerId)) {
          _lastSignalId = id;
          continue;
        }
        try {
          await _processSignal(signal);
          _lastSignalId = id;
        } on Object catch (error, stackTrace) {
          debugPrint('Call signal $id could not be processed: $error');
          debugPrintStack(stackTrace: stackTrace);
          if (mounted && !_connected) {
            setState(() => _status = 'Negotiating audio...');
          }
          break;
        }
      }

      if (!_call.isActive && mounted) {
        _pollTimer?.cancel();
        setState(() => _status = 'Call ended');
        await Future<void>.delayed(const Duration(milliseconds: 700));
        if (mounted) Navigator.of(context).pop();
      }
    } on Object catch (error) {
      debugPrint('Call signal polling failed: $error');
      // A later poll retries brief network interruptions without consuming data.
    } finally {
      _polling = false;
    }
  }

  Future<void> _processSignal(Map<String, dynamic> signal) async {
    final type = signal['type']?.toString();
    final payload = Map<String, dynamic>.from(signal['payload'] as Map);

    if (type == 'offer') {
      await _setRemoteDescription(payload);
      _localAnswer ??= await _peerConnection!.createAnswer();
      if ((await _peerConnection!.getLocalDescription()) == null) {
        await _peerConnection!.setLocalDescription(_localAnswer!);
      }
      await ConversationService.sendSignal(_call, 'answer', {
        'sdp': _localAnswer!.sdp,
        'type': _localAnswer!.type,
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

  Map<String, dynamic> _peerConfiguration() {
    final iceServers = <Map<String, dynamic>>[
      {
        'urls': [
          'stun:stun.l.google.com:19302',
          'stun:stun1.l.google.com:19302',
        ],
      },
    ];
    final turnUrls = _turnUrls
        .split(',')
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toList();
    if (turnUrls.isNotEmpty) {
      iceServers.add({
        'urls': turnUrls,
        'username': _turnUsername,
        'credential': _turnCredential,
      });
    }

    return {
      'iceServers': iceServers,
      'iceCandidatePoolSize': 10,
    };
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    for (final track in _localStream?.getTracks() ?? <MediaStreamTrack>[]) {
      track.stop();
    }
    unawaited(_localStream?.dispose());
    unawaited(_peerConnection?.close());
    if (_rendererInitialized) {
      unawaited(_remoteRenderer.dispose());
    }
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
                Offstage(child: RTCVideoView(_remoteRenderer)),
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
