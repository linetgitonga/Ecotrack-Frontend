import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

import '../connectivity/connection_manager.dart';
import '../connectivity/connection_state.dart';
import '../constants/app_constants.dart';
import 'outbox_processor.dart';

enum SyncStatus { idle, syncing, error }

/// Orchestrates uplink (outbox drain) and downlink (periodic pull) sync.
///
/// Triggers (plan §2.4):
///   * network regained → immediate drain,
///   * foreground timer every 5 min while online,
///   * an explicit [syncNow] (pull-to-refresh),
///   * `workmanager` every 15 min (wired in `background_worker.dart`).
///
/// Downlink pulls are registered by repositories via [registerPuller].
@lazySingleton
class SyncEngine {
  SyncEngine(this._outbox, this._connection, this._connectivity);

  final OutboxProcessor _outbox;
  final ConnectionManager _connection;
  final Connectivity _connectivity;

  final _statusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get status => _statusController.stream;
  SyncStatus _status = SyncStatus.idle;
  SyncStatus get currentStatus => _status;

  final _pullers = <String, Future<void> Function()>{};
  StreamSubscription<List<ConnectivityResult>>? _netSub;
  Timer? _foregroundTimer;
  bool _running = false;

  void registerPuller(String key, Future<void> Function() pull) =>
      _pullers[key] = pull;

  void start() {
    _netSub ??= _connectivity.onConnectivityChanged.listen((results) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        unawaited(syncNow());
      }
    });
    _foregroundTimer ??= Timer.periodic(
      AppConstants.foregroundPollInterval,
      (_) => unawaited(syncNow()),
    );
    unawaited(syncNow());
  }

  Future<void> stop() async {
    await _netSub?.cancel();
    _netSub = null;
    _foregroundTimer?.cancel();
    _foregroundTimer = null;
  }

  Future<void> dispose() async {
    await stop();
    await _statusController.close();
  }

  /// Full cycle: drain the outbox, then run downlink pullers. Coalesced.
  Future<void> syncNow() async {
    if (_running) return;
    if (_connection.current.mode == ConnectionMode.offline) return;
    _running = true;
    _emit(SyncStatus.syncing);
    try {
      await _outbox.drain();
      for (final pull in _pullers.values) {
        await pull();
      }
      _connection.markDataFresh();
      _emit(SyncStatus.idle);
    } catch (_) {
      _emit(SyncStatus.error);
    } finally {
      _running = false;
    }
  }

  void _emit(SyncStatus s) {
    _status = s;
    if (!_statusController.isClosed) _statusController.add(s);
  }
}
