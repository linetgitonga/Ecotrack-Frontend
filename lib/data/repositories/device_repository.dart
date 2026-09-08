import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../core/connectivity/connection_manager.dart';
import '../../core/connectivity/connection_state.dart';
import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/device.dart';
import '../local/database/app_database.dart';
import '../local/database/daos/device_dao.dart';
import '../local/database/daos/sync_dao.dart';
import '../remote/api/tierb_api.dart';

/// Cache-first device list + offline-tolerant commands.
///
///   * reads: local `cached_devices` stream, revalidated from the API.
///   * commands: optimistic local flip, then send; on failure / while offline
///     the command lands in the `outbox` (deduped by idempotency key) and the
///     `SyncEngine` drains it when connectivity returns.
@lazySingleton
class DeviceRepository {
  DeviceRepository(this._api, this._dao, this._sync, this._conn, this._uuid);

  final TierBApi _api;
  final DeviceDao _dao;
  final SyncDao _sync;
  final ConnectionManager _conn;
  final Uuid _uuid;

  Stream<List<Device>> watchDevices(String siteId) {
    _refresh(siteId); // fire and forget
    return _dao.watchDevices(siteId).map(
          (rows) => rows.map(_fromRow).toList(),
        );
  }

  Stream<Device?> watchDevice(String id) =>
      _dao.watchDevice(id).map((r) => r == null ? null : _fromRow(r));

  Future<void> refresh(String siteId) => _refresh(siteId, force: true);

  Future<void> _refresh(String siteId, {bool force = false}) async {
    if (!force && !await _sync.isStale('devices:$siteId')) return;
    if (_conn.current.mode == ConnectionMode.offline) return;

    final list = await _api.devices(siteId);
    if (list.isErr) return;
    await _dao.replaceForSite(
      siteId,
      list.valueOrNull!.map((d) => _companion(siteId, d)).toList(),
    );
    await _sync.markSynced('devices:$siteId');

    final live = await _api.live(siteId);
    if (live.isOk) {
      await _dao.applyLive(
        live.valueOrNull!.map((d) => (
              id: d.id,
              watts: d.watts,
              relay: d.relayState,
              reachable: d.reachable,
            )),
      );
    }
  }

  Future<void> refreshLive(String siteId) async {
    if (_conn.current.mode == ConnectionMode.offline) return;
    final live = await _api.live(siteId);
    if (live.isErr) return;
    await _dao.applyLive(
      live.valueOrNull!.map((d) => (
            id: d.id,
            watts: d.watts,
            relay: d.relayState,
            reachable: d.reachable,
          )),
    );
  }

  /// Toggle a device. Returns `Ok` immediately once the optimistic write +
  /// queue/send is done; a queued command surfaces via the outbox count.
  Future<Result<CommandOutcome>> setPower(String deviceId, bool on) async {
    final key = _uuid.v4();
    await _dao.setRelay(deviceId, on);

    if (_conn.current.mode == ConnectionMode.offline) {
      await _enqueue(deviceId, on, key);
      return const Ok(CommandOutcome.queued);
    }

    final r = await _api.sendCommand(deviceId, on: on, idempotencyKey: key);
    return r.when(
      ok: (_) => const Ok(CommandOutcome.sent),
      err: (f) async {
        if (f is NetworkFailure || f is TimeoutFailure || f is OfflineFailure) {
          await _enqueue(deviceId, on, key);
          return const Ok(CommandOutcome.queued);
        }
        // permanent (409 critical appliance, 403…): roll back the optimistic flip
        await _dao.setRelay(deviceId, !on);
        return Err<CommandOutcome>(f);
      },
    );
  }

  Future<void> _enqueue(String deviceId, bool on, String key) => _sync.enqueue(
        kind: 'command',
        priority: 20,
        idempotencyKey: key,
        payload: jsonEncode({'device_id': deviceId, 'on': on}),
        expiresAt: DateTime.now().add(const Duration(minutes: 15)),
      );

  /// Outbox handler — registered with `OutboxProcessor` in `bootstrap`.
  Future<Result<void>> handleQueuedCommand(Map<String, dynamic> payload) {
    return _api.sendCommand(
      payload['device_id'] as String,
      on: payload['on'] == true,
    );
  }

  Device _fromRow(CachedDevice r) => Device(
        id: r.id,
        name: r.name,
        deviceClass: r.deviceClass,
        relayState: r.relayState,
        reachable: r.reachable,
        roomId: r.roomId,
        roomName: r.roomName,
        watts: r.watts,
        volts: r.volts,
        amps: r.amps,
        lastSeenAt: r.lastSeenAt,
        switchable: r.switchable,
      );

  CachedDevicesCompanion _companion(String siteId, Device d) =>
      CachedDevicesCompanion.insert(
        id: d.id,
        siteId: siteId,
        name: d.name,
        deviceClass: d.deviceClass,
        roomId: Value(d.roomId),
        roomName: Value(d.roomName),
        relayState: Value(d.relayState),
        reachable: Value(d.reachable),
        switchable: Value(d.switchable),
        watts: Value(d.watts),
        volts: Value(d.volts),
        amps: Value(d.amps),
        lastSeenAt: Value(d.lastSeenAt),
        cachedAt: DateTime.now(),
      );
}

enum CommandOutcome { sent, queued }
