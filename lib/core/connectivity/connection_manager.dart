import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../data/local/preferences/app_preferences.dart';
import '../../data/local/preferences/secure_storage.dart';
import '../config/env_config.dart';
import '../network/cert_pinning.dart';
import '../network/dio_factory.dart';
import '../network/network_wiring.dart';
import 'connection_state.dart';
import 'mdns_discovery.dart';

/// Runs the LAN → cloud → offline state machine (plan §2.3) and drives the
/// connection indicator. Re-evaluates on connectivity change, app resume, a LAN
/// request failure, or a manual pull.
@lazySingleton
class ConnectionManager {
  ConnectionManager(
    this._prefs,
    this._secure,
    this._wiring,
    @Named(DioNames.lan) this._lanDio,
    this._mdns,
    this._connectivity,
  ) {
    _wiring.useConnectivity(_hasNetwork);
  }

  final EnvConfig _env = EnvConfig.instance;
  final AppPreferences _prefs;
  final SecureStorage _secure;
  final NetworkWiring _wiring;
  final Dio _lanDio;
  final MdnsDiscovery _mdns;
  final Connectivity _connectivity;

  final _controller = StreamController<EcoConnection>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _sub;

  EcoConnection _current = EcoConnection.offline();
  EcoConnection get current => _current;
  Stream<EcoConnection> get stream => _controller.stream;

  bool _resolving = false;

  Future<void> start() async {
    _sub ??= _connectivity.onConnectivityChanged.listen((_) => refresh());
    await refresh();
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _controller.close();
  }

  /// Re-run the state machine. Safe to call repeatedly (coalesced).
  Future<void> refresh() async {
    if (_resolving) return;
    _resolving = true;
    try {
      final next = await _resolve();
      if (next.mode != _current.mode ||
          next.hubBaseUrl != _current.hubBaseUrl) {
        _current = next;
        _controller.add(next);
      } else {
        _current = next; // keep timestamps fresh
      }
    } finally {
      _resolving = false;
    }
  }

  /// Call when a LAN request fails mid-session so we fall back promptly.
  void reportLanFailure() {
    if (_current.mode == ConnectionMode.lan) refresh();
  }

  /// 'auto' | 'lan_only' | 'cloud_only' — persisted per-installation.
  Future<void> setTransportPreference(String preference) async {
    await _prefs.setPreferredTransport(preference);
    await refresh();
  }

  Future<EcoConnection> _resolve() async {
    if (!await _hasNetwork()) {
      return EcoConnection.offline(
        since: DateTime.now(),
        lastDataAt: _current.lastDataAt,
      );
    }

    // 1. LAN — unless the user disabled it or we're on the web.
    if (_prefs.preferredTransport != 'cloud_only' &&
        _prefs.discoveryMode != 'off') {
      final lan = await _tryLan();
      if (lan != null) return lan;
    }

    // 2. Cloud reachability — any HTTP answer counts; only transport errors don't.
    if (_prefs.preferredTransport != 'lan_only' && await _cloudReachable()) {
      // TODO(phase-b): downgrade to cloudHubOffline when GET /hubs/{id} shows a
      // stale heartbeat. Hub endpoints are Tier B.
      return EcoConnection(mode: ConnectionMode.cloud, since: DateTime.now());
    }

    return EcoConnection.offline(
      since: DateTime.now(),
      lastDataAt: _current.lastDataAt,
    );
  }

  Future<EcoConnection?> _tryLan() async {
    final hub = await _mdns.findFirst(timeout: _prefs.lanTimeout);
    if (hub == null) return null;

    final fingerprint = await _secure.readHubFingerprint(hub.serial);
    final token = await _secure.readHubLocalToken(hub.serial);
    final pinner = fingerprint == null
        ? null
        : CertificatePinner(fingerprint, host: hub.host);

    bindLanTransport(
      _lanDio,
      baseUrl: hub.baseUrl,
      bearerToken: token,
      pinner: pinner,
    );

    try {
      // /identity is unauthenticated — cheapest liveness + trust check.
      await _lanDio.get<Object?>('/identity');
      return EcoConnection(
        mode: ConnectionMode.lan,
        since: DateTime.now(),
        hubId: hub.serial,
        hubBaseUrl: hub.baseUrl,
      );
    } on DioException {
      return null; // pin mismatch, unreachable, etc.
    }
  }

  Future<bool> _cloudReachable() async {
    try {
      await Dio(
        BaseOptions(
          baseUrl: _env.apiBaseUrl,
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
          validateStatus: (_) => true, // 404/401 still means "cloud is up"
        ),
      ).get<Object?>('/health');
      return true;
    } on DioException catch (e) {
      return e.response != null; // got an HTTP response despite the error
    } catch (_) {
      return false;
    }
  }

  Future<bool> _hasNetwork() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Record that fresh data arrived (drives "updated Nm ago" while offline).
  void markDataFresh() {
    _current = _current.copyWith(lastDataAt: DateTime.now());
  }
}
