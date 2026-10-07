import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../models/reservation_call.dart';
import '../services/api_client.dart';
import '../services/call_environment.dart';
import '../services/conversation_service.dart';
import '../services/permission_service.dart';
import '../utils/audio_routing_helper.dart';

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
  static const _turnUrls = String.fromEnvironment(
    'WEBRTC_TURN_URLS',
    defaultValue:
        'turn:openrelay.metered.ca:80,turn:openrelay.metered.ca:443,turn:openrelay.metered.ca:443?transport=tcp,turns:openrelay.metered.ca:443,turns:openrelay.metered.ca:443?transport=tcp',
  );
  static const _turnUsername = String.fromEnvironment(
    'WEBRTC_TURN_USERNAME',
    defaultValue: 'openrelayproject',
  );
  static const _turnCredential = String.fromEnvironment(
    'WEBRTC_TURN_CREDENTIAL',
    defaultValue: 'openrelayproject',
  );

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  Timer? _pollTimer;
  Timer? _connectionTimeoutTimer;
  late ReservationCall _call;
  final List<RTCIceCandidate> _pendingCandidates = [];
  RTCSessionDescription? _localAnswer;
  int _lastSignalId = 0;
  bool _remoteDescriptionSet = false;
  bool _rendererInitialized = false;
  bool _connected = false;
  bool _muted = false;
  bool _speakerOn = false;
  bool _busy = true;
  bool _polling = false;
  bool _setupFailed = false;
  bool _needsPermissionSettings = false;
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
        _needsPermissionSettings = false;
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
          _needsPermissionSettings = false;
          _status = 'Connecting...';
        });
      }

      // Check and request microphone permission before opening media stream
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        var hasMic = await MicrophonePermissionHelper.hasPermission();
        if (!hasMic) {
          hasMic = await MicrophonePermissionHelper.requestPermission();
        }
        if (!hasMic) {
          if (!mounted) return;
          setState(() {
            _busy = false;
            _setupFailed = true;
            _needsPermissionSettings = true;
            _status = microphonePermissionMessage;
          });
          return;
        }
      }

      if (_call.isIncoming && _call.status == 'ringing') {
        _call = await ConversationService.acceptCall(_call);
      }

      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': false,
      });

      if (!kIsWeb) {
        unawaited(AudioRoutingHelper.setSpeakerphoneOn(_speakerOn));
      }

      if (kIsWeb && !_rendererInitialized) {
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
        if (event.track.kind != 'audio') return;
        event.track.enabled = true;
        if (event.streams.isNotEmpty) {
          _remoteRenderer.srcObject = event.streams.first;
        }
        if (mounted && !_connected) {
          _connectionTimeoutTimer?.cancel();
          _connectionTimeoutTimer = null;
          setState(() {
            _connected = true;
            _status = 'Connected';
          });
        }
        if (!kIsWeb) {
          unawaited(AudioRoutingHelper.setSpeakerphoneOn(_speakerOn));
        }
      };
      _peerConnection!.onConnectionState = (state) {
        if (!mounted) return;
        final isConnected =
            state == RTCPeerConnectionState.RTCPeerConnectionStateConnected;
        if (isConnected && !_connected && !kIsWeb) {
          unawaited(AudioRoutingHelper.setSpeakerphoneOn(_speakerOn));
        }
        final wasConnected = _connected;
        setState(() {
          _connected = isConnected;
          _status = switch (state) {
            RTCPeerConnectionState.RTCPeerConnectionStateConnected =>
              'Connected',
            RTCPeerConnectionState.RTCPeerConnectionStateFailed =>
              'Connection failed',
            RTCPeerConnectionState.RTCPeerConnectionStateDisconnected =>
              'Disconnected',
            RTCPeerConnectionState.RTCPeerConnectionStateClosed =>
              'Call ended',
            _ => _call.status == 'ringing' ? 'Ringing...' : 'Connecting...',
          };
        });
        if (wasConnected &&
            (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
             state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
             state == RTCPeerConnectionState.RTCPeerConnectionStateClosed)) {
          _pollTimer?.cancel();
          if (mounted) Navigator.of(context).pop();
        }
      };
      _peerConnection!.onIceConnectionState = (state) {
        if (!mounted) return;
        if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
            state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
          if (!_connected && !kIsWeb) {
            unawaited(AudioRoutingHelper.setSpeakerphoneOn(_speakerOn));
          }
          _connectionTimeoutTimer?.cancel();
          _connectionTimeoutTimer = null;
          setState(() {
            _connected = true;
            _status = 'Connected';
          });
          // Connection established; relax polling frequency to 800ms to reduce network & server load
          _pollTimer?.cancel();
          _pollTimer = Timer.periodic(
            const Duration(milliseconds: 800),
            (_) => unawaited(_pollSignals()),
          );
        } else if (_connected &&
            (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected ||
             state == RTCIceConnectionState.RTCIceConnectionStateFailed ||
             state == RTCIceConnectionState.RTCIceConnectionStateClosed)) {
          _pollTimer?.cancel();
          if (mounted) Navigator.of(context).pop();
        }
      };

      if (!_call.isIncoming) {
        final offer = await _peerConnection!.createOffer({
          'offerToReceiveAudio': true,
        });
        await _peerConnection!.setLocalDescription(offer);
        await ConversationService.sendSignal(_call, 'offer', {
          'sdp': _sanitizeSdp(offer.sdp ?? ''),
          'type': offer.type,
        });
        unawaited(_pollSignals());
      }

      if (mounted) {
        setState(() {
          _busy = false;
          _setupFailed = false;
          _status = _call.status == 'ringing' ? 'Ringing...' : 'Connecting...';
        });
      }
      _connectionTimeoutTimer?.cancel();
      _connectionTimeoutTimer = Timer(const Duration(seconds: 50), () {
        if (mounted && !_connected) {
          unawaited(ConversationService.endCall(_call).catchError((_) => _call));
          Navigator.of(context).pop();
        }
      });
      await _pollSignals();
      _pollTimer = Timer.periodic(
        const Duration(milliseconds: 450),
        (_) => unawaited(_pollSignals()),
      );
    } on Object catch (error) {
      if (!mounted) return;
      final msg = error is ApiException
          ? error.message
          : callSetupErrorMessage(error);
      final errorStr = error.toString().toLowerCase();
      final isPermError = msg == microphonePermissionMessage ||
          errorStr.contains('permission') ||
          errorStr.contains('mediastreamtrack') ||
          errorStr.contains('failed to create new track') ||
          errorStr.contains('securityexception') ||
          errorStr.contains('bluetooth_connect');
      setState(() {
        _busy = false;
        _setupFailed = true;
        _needsPermissionSettings = isPermError;
        _status = msg;
      });
    }
  }

  Future<void> _retrySetup() async {
    if (_busy) return;
    await _start();
  }

  Future<void> _releaseMedia() async {
    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer = null;
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
    if (!kIsWeb) {
      unawaited(AudioRoutingHelper.resetAudioRoute());
    }
    _speakerOn = false;
    _muted = false;
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
        if (_status != 'Connecting audio...') {
          setState(() => _status = 'Connecting audio...');
          _connectionTimeoutTimer?.cancel();
          _connectionTimeoutTimer = Timer(const Duration(seconds: 35), () {
            if (mounted && !_connected) {
              unawaited(ConversationService.endCall(_call).catchError((_) => _call));
              Navigator.of(context).pop();
            }
          });
        }
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
    if (type == 'bye') {
      if (mounted) {
        _pollTimer?.cancel();
        Navigator.of(context).pop();
      }
      return;
    }

    final payload = Map<String, dynamic>.from(signal['payload'] as Map);

    if (type == 'offer') {
      await _setRemoteDescription(payload);
      _localAnswer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(_localAnswer!);
      await ConversationService.sendSignal(_call, 'answer', {
        'sdp': _sanitizeSdp(_localAnswer!.sdp ?? ''),
        'type': _localAnswer!.type,
      });
      unawaited(_pollSignals());
    } else if (type == 'answer') {
      await _setRemoteDescription(payload);
    } else if (type == 'ice') {
      final candidateStr = payload['candidate']?.toString();
      if (candidateStr != null && candidateStr.isNotEmpty) {
        final candidate = RTCIceCandidate(
          candidateStr,
          payload['sdpMid']?.toString(),
          (payload['sdpMLineIndex'] as num?)?.toInt(),
        );
        if (_remoteDescriptionSet) {
          try {
            await _peerConnection?.addCandidate(candidate);
          } catch (e) {
            debugPrint('Error adding ICE candidate: $e');
          }
        } else {
          _pendingCandidates.add(candidate);
        }
      }
    }
  }

  Future<void> _setRemoteDescription(Map<String, dynamic> payload) async {
    if (_remoteDescriptionSet) return;
    final sdp = _sanitizeSdp(payload['sdp']?.toString() ?? '');
    await _peerConnection?.setRemoteDescription(
      RTCSessionDescription(
        sdp,
        payload['type']?.toString(),
      ),
    );
    _remoteDescriptionSet = true;
    for (final candidate in _pendingCandidates) {
      try {
        await _peerConnection?.addCandidate(candidate);
      } catch (e) {
        debugPrint('Error adding queued candidate: $e');
      }
    }
    _pendingCandidates.clear();
  }

  static String _sanitizeSdp(String raw) {
    if (raw.isEmpty) return raw;
    final normalized = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final lines = normalized.split('\n');
    final validLines = lines.where((l) => l.trim().isNotEmpty).toList();
    if (validLines.isEmpty) return raw;
    return '${validLines.join('\r\n')}\r\n';
  }

  void _toggleMute() {
    _muted = !_muted;
    for (final track
        in _localStream?.getAudioTracks() ?? <MediaStreamTrack>[]) {
      track.enabled = !_muted;
    }
    setState(() {});
  }

  void _toggleSpeaker() {
    _speakerOn = !_speakerOn;
    if (!kIsWeb) {
      unawaited(AudioRoutingHelper.setSpeakerphoneOn(_speakerOn));
    }
    setState(() {});
  }

  Future<void> _hangUp() async {
    if (_busy) return;
    _busy = true;
    final callToEnd = _call;
    _pollTimer?.cancel();
    _pollTimer = null;

    // Immediately pop the screen and clean up media for 0ms hangup latency
    if (mounted) Navigator.of(context).pop();
    unawaited(_releaseMedia());

    // Disconnect server session in the background
    unawaited(
      ConversationService.sendSignal(callToEnd, 'bye', {}).catchError((_) {}),
    );
    unawaited(
      ConversationService.endCall(callToEnd).catchError((_) => callToEnd),
    );
  }

  Map<String, dynamic> _peerConfiguration() {
    final iceServers = <Map<String, dynamic>>[
      {
        'urls': [
          'stun:stun.l.google.com:19302',
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302',
          'stun:stun3.l.google.com:19302',
          'stun:stun4.l.google.com:19302',
          'stun:stun.cloudflare.com:3478',
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
        'username': _turnUsername.isNotEmpty ? _turnUsername : null,
        'credential': _turnCredential.isNotEmpty ? _turnCredential : null,
      });
    }

    return {
      'iceServers': iceServers,
      'iceCandidatePoolSize': 10,
    };
  }

  @override
  void dispose() {
    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer = null;
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
                if (kIsWeb)
                  SizedBox(
                    width: 1,
                    height: 1,
                    child: Opacity(
                      opacity: 0.01,
                      child: RTCVideoView(_remoteRenderer),
                    ),
                  ),
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
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      if (_needsPermissionSettings && !kIsWeb)
                        OutlinedButton.icon(
                          onPressed: MicrophonePermissionHelper.openAppSettings,
                          icon: const Icon(Icons.settings),
                          label: const Text('Open Settings'),
                        ),
                      OutlinedButton.icon(
                        onPressed: _busy ? null : _retrySetup,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try again'),
                      ),
                    ],
                  ),
                ],
                if (_muted) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.errorContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.error.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mic_off, size: 16, color: colors.onErrorContainer),
                        const SizedBox(width: 6),
                        Text(
                          'Your microphone is muted',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colors.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 36),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Mute / Unmute Button with distinct styling
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 58,
                          height: 58,
                          child: IconButton.filled(
                            onPressed: _busy ? null : _toggleMute,
                            tooltip: _muted ? 'Unmute microphone' : 'Mute microphone',
                            style: IconButton.styleFrom(
                              backgroundColor: _muted
                                  ? colors.error
                                  : colors.surfaceContainerHighest,
                              foregroundColor: _muted
                                  ? colors.onError
                                  : colors.onSurfaceVariant,
                            ),
                            icon: Icon(
                              _muted ? Icons.mic_off : Icons.mic,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _muted ? 'Muted' : 'Mute',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: _muted ? FontWeight.bold : FontWeight.w500,
                            color: _muted ? colors.error : colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (!kIsWeb) ...[
                      const SizedBox(width: 28),
                      // Loudspeaker Button with clear state
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 58,
                            height: 58,
                            child: IconButton.filled(
                              onPressed: _busy ? null : _toggleSpeaker,
                              tooltip: _speakerOn ? 'Switch to device earpiece' : 'Turn loudspeaker on',
                              style: IconButton.styleFrom(
                                backgroundColor: _speakerOn
                                    ? colors.primary
                                    : colors.surfaceContainerHighest,
                                foregroundColor: _speakerOn
                                    ? colors.onPrimary
                                    : colors.onSurfaceVariant,
                              ),
                              icon: Icon(
                                _speakerOn ? Icons.volume_up : Icons.volume_down,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _speakerOn ? 'Speaker ON' : 'Speaker',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _speakerOn ? FontWeight.bold : FontWeight.w500,
                              color: _speakerOn ? colors.primary : colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(width: 28),
                    // End Call Button
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 58,
                          height: 58,
                          child: IconButton.filled(
                            onPressed: _busy ? null : _hangUp,
                            tooltip: 'End call',
                            style: IconButton.styleFrom(
                              backgroundColor: colors.error,
                              foregroundColor: colors.onError,
                            ),
                            icon: const Icon(Icons.call_end, size: 28),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'End',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.error,
                          ),
                        ),
                      ],
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
