import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/env_config.dart';
import '../constants/api_endpoints.dart';

/// A realtime event from the cloud `WSS /v1/stream` or the LAN `/events` socket.
class RealtimeEvent {
  RealtimeEvent(this.type, this.data);
  final String type; // telemetry.tick | device.state | alert.opened | ...
  final Map<String, dynamic> data;

  static RealtimeEvent? tryParse(Object? frame) {
    try {
      final json = jsonDecode(
        frame is String ? frame : utf8.decode(frame as List<int>),
      );
      if (json is Map && json['type'] is String) {
        return RealtimeEvent(
          json['type'] as String,
          (json['data'] as Map?)?.cast<String, dynamic>() ?? const {},
        );
      }
    } catch (_) {}
    return null;
  }
}

/// Multiplexes the realtime socket into a broadcast [events] stream, with
/// exponential-backoff reconnect. `connect` is idempotent; `disconnect` stops
/// reconnection.
@lazySingleton
class RealtimeClient {
  final _controller = StreamController<RealtimeEvent>.broadcast();
  Stream<RealtimeEvent> get events => _controller.stream;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  Timer? _reconnectTimer;
  Uri? _target;
  int _attempt = 0;
  bool _wantConnection = false;

  bool get isConnected => _channel != null;

  /// Connect to the cloud stream for a site. Pass a LAN `wss://…/events` URI to
  /// [overrideUri] when a LAN session is active.
  void connect({required String siteId, Uri? overrideUri}) {
    _wantConnection = true;
    _target =
        overrideUri ??
        Uri.parse(_wsBase()).replace(
          path:
              '${Uri.parse(EnvConfig.instance.apiBaseUrl).path}${ApiPaths.stream}',
          queryParameters: {'site_id': siteId},
        );
    _open();
  }

  void disconnect() {
    _wantConnection = false;
    _reconnectTimer?.cancel();
    _sub?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  Future<void> dispose() async {
    disconnect();
    await _controller.close();
  }

  void _open() {
    if (_target == null) return;
    _sub?.cancel();
    _channel?.sink.close();
    try {
      _channel = WebSocketChannel.connect(_target!);
      _sub = _channel!.stream.listen(
        (frame) {
          _attempt = 0;
          final event = RealtimeEvent.tryParse(frame);
          if (event != null) _controller.add(event);
        },
        onDone: _scheduleReconnect,
        onError: (_) => _scheduleReconnect(),
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _channel = null;
    if (!_wantConnection) return;
    _reconnectTimer?.cancel();
    final delaySeconds = (1 << _attempt.clamp(0, 5)).clamp(1, 32);
    _attempt++;
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), _open);
  }

  String _wsBase() {
    final api = EnvConfig.instance.apiBaseUrl;
    return api
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');
  }
}
